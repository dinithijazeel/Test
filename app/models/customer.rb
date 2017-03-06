#
# Customer
#
class Customer < Contact
  #
  ## Associations
  #
  has_many :open_invoices, -> { where(type: ['Invoice','ServiceInvoice']).where(invoice_status: Invoice.invoice_statuses[:open]).order(invoice_date: :desc) }, foreign_key: :contact_id, class_name: 'Bom'
  has_many :balance_invoices, -> { where(type: ['Invoice','ServiceInvoice']).where(invoice_status: [Invoice.invoice_statuses[:open], Invoice.invoice_statuses[:paid], Invoice.invoice_statuses[:closed]]).order(invoice_date: :desc) }, foreign_key: :contact_id, class_name: 'Bom'
  has_many :invoices, -> { where(type: ['Invoice','ServiceInvoice']).order(invoice_date: :desc) }, foreign_key: :contact_id, class_name: 'Bom'
  has_many :payments, -> { where.not(payment_account: 'Credit').order(payment_date: :desc) }
  has_many :credits, -> { where(payment_account: 'Credit').order(payment_date: :desc) }, class_name: 'Payment'

  accepts_nested_attributes_for :opportunity, :reject_if => :all_blank, :allow_destroy => true
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
  def payment_link
    Rails.application.routes.url_helpers.account_payment_url(payment_token)
  end

  def payment_token
    recent_invoice = balance_invoices.first
    if recent_invoice
      recent_invoice.payment_token
    else
      'xxxx-xxxx-xxxx-xxxx'
    end
  end

  def payment_invoices
    open_invoices
  end

  def payable_amount
    open_invoices.sum(:total_due)
  end

  def status_label
    I18n.t :"activerecord.attributes.customer.customer_statuses.#{customer_status}"
  end

  def payable_name
    company_name
  end

  def total_charges
    if balance_invoices.empty?
      0
    else
      balance_invoices.sum(:invoice_total)
    end
  end

  def last_charge
    if balance_invoices.empty?
      0
    else
      # Invoices are in reverse chronological order
      balance_invoices.first.invoice_total
    end
  end

  def total_payments
    if payments.empty?
      0
    else
      payments.sum(:amount)
    end
  end

  def last_payments
    if payments.empty?
      0
    else
      payments.inject(0) { |m, p| p.payment_date < previous_balance_date ? m : m + p.amount }
    end
  end

  def total_credits
    if credits.empty?
      0
    else
      credits.sum(:amount)
    end
  end

  def last_credits
    if credits.empty?
      0
    else
      credits.inject(0) { |m, c| c.payment_date < previous_balance_date ? m : m + c.amount }
    end
  end

  def previous_balance
    current_balance - last_charge + last_payments + last_credits
  end

  def previous_balance_date
    if balance_invoices.count > 1
      balance_invoices[1].invoice_date
    elsif balance_invoices.count == 1
      balance_invoices.first.invoice_date
    else
      1.day.ago
    end
  end

  def adjustments
    last_credits
  end

  def current_balance
    total_charges - total_payments - total_credits
  end

  def generate_statement
    Pdf.generate(statement_template, instance_vars: {customer: self})
    # pdf = Pdf.generate(statement_template, instance_vars: {customer: self})
    # update_attribute(:pdf, File.open(pdf))
  end

  def statement_template
    'customers/pdf/statement_pdf.html.slim'
  end

  def statement_filename
    "Statement-#{Date.today}-#{company_name.gsub(/[^\- 0-9a-z]/i, '')}.pdf"
  end

  def send_statement_later(sender_id = nil)
    # Use current user if we don't specify a sender
    sender_id = User.current.id if sender_id.nil?
    # Queue for execution
    SendStatementJob.perform_later(self.id, sender_id)
  end

  def send_statement(sender_id = nil)
    # Use current user if we don't specify a sender
    sender_id = User.current.id if sender_id.nil?
    # Send mail
    StatementMailer.statement(self).deliver_now
    # Log activity
    message = "Statement sent to #{contact.invoice_email}"
    Comment.build_from(contact, sender_id, message).save
  end

  def self.controller_params
    [ Contact.controller_params,
      opportunity_attributes: ([:id] + Opportunity.controller_params) ]
  end
end
