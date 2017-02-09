class LineItem < ActiveRecord::Base
  #
  ## Behavior
  #
  acts_as_paranoid
  #
  ## Associations
  #
  belongs_to :bom
  belongs_to :product
  #
  ## Validation
  #
  validates :product, :presence => { :message => 'Unknown or missing product' }
  #
  ## Scopes
  #
  scope :billing_type, ->(type) { joins(:product).where('products.billing = ?', Product.billings[type]) }
  #
  ## Callbacks
  #
  before_save do
    enforce_unit_price unless bom.type == 'ServiceInvoice'
    calculate_total
  end

  def self.sum(type, line_items)
    line_items.inject(0) do |a, e|
      if type == :quantity
        a + e.quantity
      else # line_items == :total
        a + e.total
      end
    end
  end

  def self.controller_params
    [ :description,
      :quantity,
      :unit_price,
      :total,
      :product_id,
      :_destroy ]
  end

  protected

  def enforce_unit_price
    # Make sure we use the DB price if this is a fixed price product
    self.unit_price = product.price if product.fixed_price
  end

  def calculate_total
    # Calculate line item total
    self.total = quantity * unit_price
  end
end
