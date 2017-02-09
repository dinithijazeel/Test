class Invoice < Bom
  #
  ## Validation
  #
  validates :terms, :presence => { :message => 'Unknown or missing terms' }
  validates :contact, :presence =>  { :message => 'Unknown or missing account' }
  #
  ## Associations
  #
  has_many :credits
  #
  ## Helpers
  #
  mount_uploader :pdf, PdfUploader
  #
  ## Scopes
  #
  scope :query, -> (q) { joins(:contact).where('boms.number LIKE ? OR boms.memo LIKE ? OR contacts.company_name LIKE ? OR contacts.contact_first LIKE ? OR contacts.contact_last LIKE ?', "%#{q.squish}%", "%#{q.squish}%", "%#{q.squish}%", "%#{q.squish}%", "%#{q.squish}%") }
  scope :updated_this_month, -> {
    where(updated_at: Time.now.beginning_of_month..Time.now.end_of_month).
    where('boms.type IN (\'Invoice\',\'ServiceInvoice\')')
  }
  #
  ## Listings
  #
  def self.index
    Bom.invoices_updated_this_month.group_by { |i| i.status_label }
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
    base = Rails.application.config.x.portal.billing_endpoint
    parameters = {
      action:        'PAYINVOICES3',
      name:          "#{contact.contact_first} #{contact.contact_last}",
      accountcode:   contact.portal_id,
      email:         contact.admin_email,
      invoiceid:     portal_id,
      invoicenumber: number,
      amount:        invoice_total
    }
    "#{base}?#{parameters.to_query}"
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
    "tenants/#{Rails.application.config.x.tenant}/invoices/standard_pdf.html.slim"
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
