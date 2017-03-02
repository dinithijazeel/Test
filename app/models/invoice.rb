class Invoice < Bom
  #
  ## Validation
  #
  validates :terms, :presence => { :message => 'Unknown or missing terms' }
  validates :contact, :presence =>  { :message => 'Unknown or missing account' }
  #
  ## Associations
  #
  has_many   :credits
  has_many   :payments, as: :payable
  belongs_to :creator, :class_name => 'User'
  #
  ## Helpers
  #
  mount_uploader :pdf, PdfUploader
  #
  ## Scopes
  #
  scope :query, -> (q) { joins(:contact).where('boms.number LIKE ? OR boms.memo LIKE ? OR contacts.company_name LIKE ? OR contacts.contact_first LIKE ? OR contacts.contact_last LIKE ? OR contacts.portal_id LIKE ?', "%#{q.squish}%", "%#{q.squish}%", "%#{q.squish}%", "%#{q.squish}%", "%#{q.squish}%", "%#{q.squish}%") }
  scope :updated_this_month, -> {
    where(updated_at: Time.now.beginning_of_month..Time.now.end_of_month).
    where('boms.type IN (\'Invoice\',\'ServiceInvoice\')')
  }
  #
  ## Listings
  #
  def self.index
    Bom.invoices_updated_this_month.order(invoice_date: :desc).group_by { |i| i.status_label }
  end

  def self.search(q)
    query(q).group_by { |i| i.status_label }
  end
  #
  ## Helpers
  #
  def status_label
    I18n.t :"activerecord.attributes.invoice.invoice_statuses.#{invoice_status}"
  end

  def payment_link
    if payment_token
      Rails.application.routes.url_helpers.payment_url(payment_token)
    else
      Rails.application.routes.url_helpers.payment_url('xxxx-xxxx-xxxx-xxxx')
    end
  end

  def pdf_filename
    if number.nil?
      prefix = "DRAFT-#{id}"
    else
      prefix = number
    end
    "#{prefix}-#{contact.company_name.gsub(/[^\- 0-9a-z]/i, '')}.pdf"
  end

  def pdf_template
    'invoices/pdf/standard_pdf.html.slim'
  end

  protected

  def set_invoice_total
    unless obsolete?
      # Calculate total
      super
      # Calculate payments
      self.total_payments = 0
      credits.each do |credit|
        self.total_payments += credit.amount unless credit.amount.nil?
      end
      # Calculate total due
      self.total_due = invoice_total - total_payments
      # Is this invoice paid or a credit invoice?
      if open? && total_due == 0
        self.invoice_status = :paid
      elsif open? && total_due < 0
        self.invoice_status = :credit
      elsif !draft? && total_due > 0
        self.invoice_status = :open
      end
      # Fill in missing memo
      if memo.nil? || memo.blank?
        self.memo = summary
      end
    end
  end
end
