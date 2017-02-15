class StripeTransaction < ActiveRecord::Base
  #
  ## Associations
  #
  belongs_to :payment

  def self.controller_params
    [ :token,
      :stripe_created,
      :client_ip,
      :card_id,
      :card_type,
      :brand,
      :name,
      :exp_month,
      :exp_year,
      :last4,
      :country,
      :funding,
      :address_line1,
      :address_line2,
      :address_state,
      :address_city,
      :address_zip,
      :address_country,
      :address_line1_check,
      :address_zip_check,
      :cvc_check ]
  end
end
