#
# Customer
#
class Customer < Contact
  #
  ## Associations
  #
  has_many :invoices, :foreign_key => :contact_id
  has_many :payments
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

  def self.open_invoices(customer_id)
    invoices.where(:invoice_status => Invoice.invoice_statuses[:open])
  end

  def self.controller_params
    [ Contact.controller_params,
      opportunity_attributes: ([:id] + Opportunity.controller_params) ]
  end
end
