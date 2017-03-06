class Payment < ActiveRecord::Base
  #
  ## Validation
  #
  validate :not_negative_balance
  validate :process_payment
  validates :payment_account, :presence => true
  validates :amount, :numericality => { :greater_than_or_equal_to => 0.01, :message => 'Must be greater than $0.00' }
  validates :fee, :numericality => true
  #
  ## Associations
  #
  has_one :stripe_transaction
  has_many :credits
  has_many :invoices, :through => :credits
  belongs_to :payable, polymorphic: true
  belongs_to :customer
  belongs_to :creator, :class_name => 'User'
  belongs_to :last_editor, :class_name => 'User'
  accepts_nested_attributes_for :credits, reject_if: proc { |credit| credit['amount'].blank? || credit['amount'] == 0}
  accepts_nested_attributes_for :stripe_transaction, :reject_if => :all_blank, :allow_destroy => true
  #
  # Enumerations
  enum :payment_status => [:payment, :credit]
  #
  ## Callbacks
  #
  before_create do
    self.creator = User.current
    if payment_type.blank? && payment_account == 'Stripe'
      self.payment_type = stripe_transaction.brand
    end
    if memo.blank?
      if payment_type.blank?
        self.memo = "#{payment_account} - #{payable.payable_name}"
      else
        self.memo = "#{payment_type} - #{payable.payable_name}"
      end
    end
    self.payment_date = Time.now if payment_date.blank?
  end

  before_save do
    calculate_balance
    if balance > 0
      self.payment_status = :credit
    else
      self.payment_status = :payment
    end
  end

  after_save do
    update_invoices
  end
  #
  ## Validation
  #
  def not_negative_balance
    calculate_balance
    if balance < 0
      errors.add(:amount, 'is unbalanced')
    end
  end
  #
  ## Helpers
  #
  def calculate_balance
    self.balance = amount - credit_total
  end

  def update_invoices
    invoices.each &:recalculate
  end

  # TODO: Ditch when portal no longer records payments
  def record_portal_payment
    portal_payment = {
      :accountcode => payable_contact.account_code,
      :amount      => amount,
      :invoiceid   => payable.number,
      :paymentdata => stripe_transaction.to_json,
    }
    Fractel.record_invoice_payment(portal_payment)
  end

  def record_portal_prepayment
    portal_payment = {
      :accountcode => payable_contact.account_code,
      :amount      => amount,
      :invoiceid   => payable.number,
      :paymentdata => stripe_transaction.to_json,
    }
    Fractel.record_prepaid_payment(portal_payment)
  end

  def credit_total
    credit_total = 0
    credits.each do |credit|
      credit_total += credit.amount unless credit.amount.nil?
    end
    credit_total
  end

  def invoice_total
    invoice_total = 0
    credits.each do |credit|
      invoice_total += credit.invoice.total_due
    end
    invoice_total
  end

  def payable_contact
    case payable.class.name
    when 'Customer'
      payable
    else
      payable.contact
    end
  end

  def self.payments_accepted
    payments = []
    Conf.payments.each do |payment_type, payment_accounts|
      if Pundit.policy(User.current, :payment).send("use_#{payment_type}?")
        payment_accounts.each do |account|
          payments << [account, 'data-form' => payment_type]
        end
      end
    end
    payments.compact
  end

  def self.payment_forms
    Conf.payments.keys
  end

  def self.bank_deposits
    [
      'Check',
      'Cash',
      'Credit Card',
      'ACH',
      'Wire',
      'Paypal',
      'Other',
    ]
  end

  def self.credits
    [
      'SLA',
      'Billing Error',
      'Service Adjustment',
      'Refund',
      'Warranty',
      'RMA',
      'Return',
      'Other',
    ]
  end

  def self.controller_params
    [ :payment_account,
      :payment_type,
      :payment_date,
      :amount,
      :fee,
      :memo,
      :customer_id,
      :payable_id,
      :payable_type,
      :credits_attributes => ([:id] + Credit.controller_params),
      :stripe_transaction_attributes => (StripeTransaction.controller_params) ]
  end

  def process_payment
    # Process Stripe payments
    # TODO: This should probably be a property, eg "if remote_transaction?"
    unless payment_account != 'Stripe' || stripe_transaction.token.empty? || (amount <= 0)
      begin
        Stripe::Charge.create(
          :amount => (amount * 100).to_i, # amount in cents
          :currency => 'usd',
          :source => stripe_transaction.token,
          :description => memo
        )
        true
      rescue Stripe::CardError => e
        errors.add(:card_error, e.message)
        false
      end
    end
  end
end
