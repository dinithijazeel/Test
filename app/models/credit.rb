class Credit < ActiveRecord::Base
  #
  ## Associations
  #
  belongs_to :invoice
  belongs_to :payment
  belongs_to :creator, :class_name => 'User'
  #
  ## Callbacks
  #
  before_create do
    self.creator = User.current
  end

  def self.controller_params
    [ :invoice_id,
      :amount ]
  end

end
