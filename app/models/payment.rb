class Payment < ActiveRecord::Base
  #
  ## Validation
  #
  validate :not_negative_balance
  validates :payment_type, :presence => true
  validates :amount, :numericality => { :greater_than_or_equal_to => 0.01, :message => 'Must be greater than $0.00' }
  validates :fee, :numericality => true
  #
  ## Associations
  #
  has_many :credits
  has_many :invoices, :through => :credits
  belongs_to :customer
  belongs_to :creator, :class_name => 'User'
  belongs_to :last_editor, :class_name => 'User'
  has_one :stripe_transaction
  accepts_nested_attributes_for :credits
  accepts_nested_attributes_for :stripe_transaction, :reject_if => :all_blank, :allow_destroy => true
  #
  # Enumerations
  enum :payment_status => [:payment, :credit]
  #
  ## Callbacks
  #
  before_create do
    self.creator = User.current
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

  def self.bank_deposits
    [
      'Check',
      'Cash',
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
end
