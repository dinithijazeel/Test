class Product < ActiveRecord::Base
  #
  # Associations
  belongs_to :vendor
  belongs_to :product_category
  #
  # Validation
  # validates :sku, :presence => true
  validates :name, :presence => true
  validates :price, :presence => true
  #
  # Enumeration
  enum :product_status => [:active, :billing, :inactive]
  enum :product_type => [:other_type, :service, :merchandise, :tax, :shipping]
  enum :billing => [:other_billing, :non_recurring, :recurring, :usage, :taxes]
  #
  # Helpers
  #
  mount_uploader :datasheet, DatasheetUploader
  #
  ## Scopes
  #
  scope :query, -> (q) { joins('LEFT JOIN `vendors` ON `vendors`.`id` = `products`.`vendor_id`').where('vendors.name LIKE ? OR products.sku LIKE ? OR products.name LIKE ? OR products.description LIKE ?', "%#{q.squish}%", "%#{q.squish}%", "%#{q.squish}%", "%#{q.squish}%") }
  #
  ## Listings
  #
  def self.index
    all.group_by { |i| i.product_type_label }
  end

  def self.search(q)
    query(q).group_by { |i| i.product_type_label }
  end

  def self.get(special_product)
    # Get SKU
    product_sku = Conf.products.special[special_product]
    # Get product
    find_by_sku(product_sku)
  end

  def self.type_listing(type)
    where(:product_type => product_types[type]).order(:product_status, :billing, :name).all
  end

  # View Helpers

  def product_status_label
    I18n.t :"activerecord.attributes.product.product_statuses.#{product_status}"
  end

  def product_type_label
    I18n.t :"activerecord.attributes.product.product_types.#{product_type}"
  end

  def billing_label
    I18n.t :"activerecord.attributes.product.billings.#{billing}"
  end

  def self.collection(type = false)
    case type
    when :services_proposal, :recurring_services
      services = Product.where(:billing => billings[:recurring]).where(:product_status => product_statuses[:active]).order(:name).pluck(:name, :id)
      services << Product.collection_item(:discount)
      services << Product.collection_item(:sales_tax)
      services.compact
    when :products_proposal, :merchandise
      products = Product.where(:billing => billings[:non_recurring]).where(:product_status => product_statuses[:active]).order(:name).pluck(:name, :id)
      products << Product.collection_item(:discount)
      products << Product.collection_item(:sales_tax)
      products << Product.collection_item(:shipping)
      products.compact
    else
      Product.order(:name).pluck(:name, :id)
    end
  end

  def self.collection_item(product_label)
    product = get(product_label)
    if product
      [product.name, product.id]
    else
      nil
    end
  end

  def self.controller_params
    [ :sku,
      :billing,
      :product_type,
      :product_status,
      :fixed_price,
      :datasheet,
      :name,
      :description,
      :price,
      :weight,
      :units,
      :vendor_sku,
      :vendor_id,
      :default_quantity ]
  end
end
