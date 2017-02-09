class StripeTransaction < ActiveRecord::Base
  #
  ## Associations
  #
  belongs_to :payment
end
