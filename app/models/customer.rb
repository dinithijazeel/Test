#
# Customer
#
class Customer < Contact
  #
  ## Associations
  #
  has_many :invoices, -> { where(type: ['Invoice','ServiceInvoice']) }, foreign_key: :contact_id, class_name: 'Bom'
  has_many :payments
  has_many :credits, -> { where(payment_status: Payment.payment_statuses[:credit])}, class_name: 'Payment'

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
  def status_label
    I18n.t :"activerecord.attributes.customer.customer_statuses.#{customer_status}"
  end

  def payable_amount
    0.0
  end

  def payable_name
    company_name
  end

  def self.controller_params
    [ Contact.controller_params,
      opportunity_attributes: ([:id] + Opportunity.controller_params) ]
  end
end
