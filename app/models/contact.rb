#
# Contact
#
class Contact < ActiveRecord::Base
  #
  ## Behavior
  #
  acts_as_commentable
  #
  ## Associations
  #
  belongs_to :creator, :class_name => 'User'
  belongs_to :last_editor, :class_name => 'User'
  has_one :opportunity
  has_many :proposals
  #
  ## Validation
  #
  validates :admin_email, :email => true, :uniqueness => { :message => 'already exists' }
  #
  ## Enumerations
  #
  enum :default_terms => [:net10, :net30, :due, :special_terms]
  enum :customer_status => [:lead, :opportunity, :prospect, :signup, :pre_production, :production, :canceled]
  #
  ## Scopes
  #
  scope :query, -> (q) { where('company_name LIKE ? OR contact_first LIKE ? OR contact_last LIKE ? OR admin_email LIKE ? OR billing_email LIKE ? OR phone LIKE ? OR portal_id LIKE ?', "%#{q.squish}%", "%#{q.squish}%", "%#{q.squish}%", "%#{q.squish}%", "%#{q.squish}%", "%#{q.squish}%", "%#{q.squish}%") }
  scope :updated_this_week, -> {
    where(updated_at: 1.weeks.ago..Time.now).
    order(updated_at: :desc)
  }
  scope :updated_this_month, -> {
    where(updated_at: 4.weeks.ago..Time.now).
    order(updated_at: :desc)
  }
  #
  ## Callbacks
  #
  before_save do
    if use_billing_for_service
      self.service_street_1 = billing_street_1
      self.service_street_2 = billing_street_2
      self.service_city = billing_city
      self.service_state = billing_state
      self.service_zip = billing_zip
      self.service_country = billing_country
    end
  end

  before_create do
    self.creator = User.current
  end

  before_update do
    self.last_editor = User.current
    # Remove non-numbers from phone
    self.phone = phone.gsub(/\D/, '')
  end

  #
  ## Listings
  #
  def self.leads
    updated_this_week.where(customer_status: Contact.customer_statuses[:lead])
  end

  def self.opps
    updated_this_week.where(customer_status: Contact.customer_statuses[:opportunity])
  end

  def self.index
    updated_this_month.where.not(customer_status: [Contact.customer_statuses[:lead], Contact.customer_statuses[:opportunity]])
  end

  def self.search(q)
    query(q)
  end
  #
  ## LOA
  #
  def local_loa_path
    query = {
      :accountcode  => portal_id,
      :customername => company_name,
      :address1     => billing_street_1,
      :address2     => billing_street_2,
      :city         => billing_city,
      :zipcode      => billing_zip,
      :state        => billing_state,
      :firstname    => contact_first,
      :lastname     => contact_last,
      :email        => admin_email,
      :phone        => phone,
    }
    "#{Rails.configuration.x.loa.local}?#{query.to_query}"
  end

  def tollfree_loa_path
    query = {
      :accountcode  => portal_id,
      :customername => company_name,
      :address1     => billing_street_1,
      :address2     => billing_street_2,
      :city         => billing_city,
      :zipcode      => billing_zip,
      :state        => billing_state,
      :firstname    => contact_first,
      :lastname     => contact_last,
      :email        => admin_email,
      :phone        => phone,
    }
    "#{Rails.configuration.x.loa.tollfree}?#{query.to_query}"
  end

  # Portal

  def has_portal_account?
    !(portal_id.nil? || portal_id.blank?)
  end

  def portal_record
  {
    :accountcode    => portal_id,
    :firstname      => contact_first,
    :lastname       => contact_last,
    :companyname    => company_name,
    :address1       => use_billing_for_service? ? billing_street_1 : service_street_1,
    :address2       => use_billing_for_service? ? billing_street_2 : service_street_2,
    :city           => use_billing_for_service? ? billing_city : service_city,
    :state          => use_billing_for_service? ? billing_state : service_state,
    :zipcode        => use_billing_for_service? ? billing_zip : service_zip,
    :country        => use_billing_for_service? ? billing_country : service_country,
    :email          => admin_email,
    :adminemail     => admin_email,
    :billingemail   => billing_email.empty? ? admin_email : billing_email,
    :technicalemail => admin_email,
    :ratesemail     => admin_email,
    :portingemail   => admin_email,
    :workphone      => phone.gsub(/[^\d]/, ''),
  }
  end

  def update_portal_record
  {
    :AccountCode    => portal_id,
    :FirstName      => contact_first,
    :LastName       => contact_last,
    :CompanyName    => company_name,
    :Address1       => use_billing_for_service? ? billing_street_1 : service_street_1,
    :Address2       => use_billing_for_service? ? billing_street_2 : service_street_2,
    :City           => use_billing_for_service? ? billing_city : service_city,
    :State          => use_billing_for_service? ? billing_state : service_state,
    :ZipCode        => use_billing_for_service? ? billing_zip : service_zip,
    :Country        => use_billing_for_service? ? billing_country : service_country,
    :Email          => admin_email,
    :AdminEmail     => admin_email,
    :BillingEmail   => billing_email.empty? ? admin_email : billing_email,
    :TechnicalEmail => admin_email,
    :RatesEmail     => admin_email,
    :PortingEmail   => admin_email,
    :WorkPhone      => phone.gsub(/[^\d]/, ''),
  }
  end

  def read_portal_record
    if has_portal_account?
      portal_record = Fractel.get_account(customerdata: ",,#{portal_id}")
      record = {
        contact_first: portal_record['FirstName'][0],
        contact_last: portal_record['LastName'][0],
        company_name: portal_record['CompanyName'][0],
        phone: portal_record['WorkPhone'][0],
        admin_email: portal_record['AdminEmail'][0],
        billing_email: portal_record['BillingEmail'][0],
        billing_street_1: portal_record['Address1'][0],
        billing_street_2: portal_record['Address2'][0],
        billing_city: portal_record['City'][0],
        billing_state: portal_record['State'][0],
        billing_zip: portal_record['ZipCode'][0],
        billing_country: portal_record['Country'][0],
        service_street_1: portal_record['Address1'][0],
        service_street_2: portal_record['Address2'][0],
        service_city: portal_record['City'][0],
        service_state: portal_record['State'][0],
        service_zip: portal_record['ZipCode'][0],
        service_country: portal_record['Country'][0],
        use_billing_for_service: true,
        tax_exempt_certificate: portal_record['USF499ID'][0],
      }
      update_columns(record)
    end
  end

  # Helpers

  def payable_name
    company_name
  end

  def payable_amount
    # TODO: This should probably be the outstanding balance
    0
  end

  def invoice_email
    if billing_email.nil? || billing_email.empty?
      admin_email
    else
      billing_email
    end
  end

  def billing_address
    { contact:  "#{contact_first} #{contact_last}",
      company:  company_name,
      street_1: billing_street_1,
      street_2: billing_street_2,
      city:     billing_city,
      state:    billing_state,
      zip:      billing_zip,
      country:  billing_country }
  end

  def service_address
    if use_billing_for_service
      billing_address
    else
      { contact:  "#{contact_first} #{contact_last}",
        company:  company_name,
        street_1: service_street_1,
        street_2: service_street_2,
        city:     service_city,
        state:    service_state,
        zip:      service_zip,
        country:  service_country }
    end
  end

  def self.convert_to_customer(id)
    customer = find(id)
    customer.update(
      :type            => 'Customer',
      :customer_status => :opportunity
    )
  end

  def status_label
    I18n.t :"activerecord.attributes.customer.customer_statuses.#{customer_status}"
  end

  def full_name
    "#{contact_first} #{contact_last}"
  end

  def not_using_billing_for_service
    !use_billing_for_service
  end

  def self.bogus
    new(
      :admin_email      => Forgery('internet').email_address,
      :contact_first    => Forgery('name').first_name,
      :contact_last     => Forgery('name').last_name,
      :company_name     => Forgery('name').company_name,
      :phone            => Forgery('address').phone,
      :billing_street_1 => Forgery('address').street_address,
      :billing_street_2 => '',
      :billing_city     => Forgery('address').city,
      :billing_state    => Forgery('address').state_abbrev,
      :billing_zip      => Forgery('address').zip,
      :billing_country  => 'United States',
      :billing_email    => '',
      :use_billing_for_service => true,
      :affiliate_id     => '',
      :discount_code    => ''
    )
  end

  def self.controller_params
    [ :contact_first,
      :contact_last,
      :company_name,
      :phone,
      :admin_email,
      :default_terms,
      :billing_email,
      :billing_street_1,
      :billing_street_2,
      :billing_city,
      :billing_state,
      :billing_zip,
      :billing_country,
      :use_billing_for_service,
      :service_street_1,
      :service_street_2,
      :service_city,
      :service_state,
      :service_zip,
      :service_country,
      :affiliate_id,
      :discount_code ]
  end
end
