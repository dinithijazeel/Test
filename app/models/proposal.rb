class Proposal < ActiveRecord::Base
  #
  ## Validation
  #
  validates :contact, :presence => true
  #
  ## Associations
  #
  belongs_to :contact
  belongs_to :services_proposal, :class_name => 'ServicesProposal'
  belongs_to :products_proposal, :class_name => 'ProductsProposal'
  belongs_to :creator,           :class_name => 'User'
  belongs_to :last_editor,       :class_name => 'User'
  has_one    :onboarding
  accepts_nested_attributes_for :contact, :services_proposal, :products_proposal, :onboarding
  #
  ## Enumeration
  #
  enum :proposal_status => [:draft, :submitted, :accepted, :declined, :completed]
  #
  ## Helpers
  #
  mount_uploader :pdf, PdfUploader
  #
  ## Scopes
  #
  scope :query, -> (q) { joins(:contact).where('proposals.number LIKE ? OR proposals.memo LIKE ? OR contacts.company_name LIKE ? OR contacts.contact_first LIKE ? OR contacts.contact_last LIKE ?', "%#{q.squish}%", "%#{q.squish}%", "%#{q.squish}%", "%#{q.squish}%", "%#{q.squish}%") }
  scope :updated_this_month, -> { where(updated_at: Time.now.beginning_of_month..Time.now.end_of_month) }
  #
  ## Callbacks
  #
  before_create do
    self.creator = User.current
  end

  before_update do
    self.last_editor = User.current
  end

  before_save :calculate_total, :update_onboarding
  #
  ## Listings
  #
  def self.index
    updated_this_month.group_by { |i| i.status_label }
  end

  def self.search(q)
    query(q).group_by { |i| i.status_label }
  end
  #
  ## Helpers
  #
  def generate_number
    self.number = proposal_date.to_s(:number)[2..-1]
    latest = Proposal.where('number LIKE ?', "#{number}%").order('number DESC').first
    if latest.nil?
      self.number += '0001'
    else
      self.number = latest.number.succ
    end
  end

  def generate_pdf
    new_pdf = Pdf.generate(pdf_template, instance_vars: {proposal: self})
    update_attribute(:pdf, File.open(new_pdf))
    Pdf.merge(pdf.path, pdf_components)
  end

  def send_proposal_later(sender_id = nil)
    # Use current user if we don't specify a sender
    sender_id = User.current.id if sender_id.nil?
    # Queue for execution
    SendProposalJob.perform_later(self.id, sender_id)
  end

  def send_proposal(sender_id = nil)
    # Use current user if we don't specify a sender
    sender_id = User.current.id if sender_id.nil?
    # Generate fresh PDF
    generate_pdf
    # Send mail
    ProposalMailer.proposal(self).deliver_now
    # Log activity
    message = "Proposal #{number} sent to #{contact.admin_email}"
    Comment.build_from(contact, sender_id, message).save
  end

  def owner
    creator
  end

  def pdf_template
    "tenants/#{Rails.application.config.x.tenant}/proposal/pdf.html.slim"
  end

  def pdf_filename
    if number.nil?
      prefix = "DRAFT-#{id}"
    else
      prefix = number
    end
    "#{prefix}-#{contact.company_name.gsub(/[^\- 0-9a-z]/i, '')}.pdf"
  end

  def pdf_components
    proposal_path = pdf.path
    products_datasheets = products_proposal.datasheet_index.collect do |line_item|
      line_item.product.datasheet.path
    end
    [proposal_path] + products_datasheets + [Rails.application.config.x.proposals.terms, Rails.application.config.x.proposals.back_cover]
  end

  def self.controller_params
    [ :contact_id,
      :memo,
      :services_proposal_attributes => ([:id] + Invoice.controller_params),
      :products_proposal_attributes => ([:id] + Invoice.controller_params),
      :onboarding_attributes => ([:id] + Onboarding.controller_params) ]
  end
  #
  ## View Helpers
  #
  def status_label
    I18n.t :"activerecord.attributes.proposal.proposal_statuses.#{proposal_status}"
  end

  def services
    services_proposal.summary("\n\n")
  end

  def equipment_list
    products_proposal.summary("\n\n")
  end

  #
  ## Privates!
  #
  protected

  def calculate_total
    self.total = 0
    self.total += services_proposal.invoice_total unless services_proposal.nil?
    self.total += products_proposal.invoice_total unless products_proposal.nil?
  end

  def update_onboarding
    onboarding.read_bom(services_proposal)
  end
end
