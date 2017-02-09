class CreateStripeTransactions < ActiveRecord::Migration
  def change
    create_table :stripe_transactions do |t|
      #
      # Stripe
      t.string  :token, :index => true, :null => false
      t.integer :stripe_created
      #
      # Card
      t.string :card_id,   :null => false
      t.string :card_type, :null => false
      t.string :brand,     :null => false
      t.string :name,      :null => false
      t.integer :exp_month
      t.integer :exp_year
      t.integer :last4
      t.string :country, :null => false
      t.string :funding, :null => false
      #
      # Address
      t.string :address_line1,   :null => false
      t.string :address_line2,   :null => false
      t.string :address_state,   :null => false
      t.string :address_city,    :null => false
      t.string :address_zip,     :null => false
      t.string :address_country, :null => false
      #
      # Checks
      t.string :address_line1_check, :null => false
      t.string :address_zip_check,   :null => false
      t.string :cvc_check,           :null => false
      #
      # Associations
      t.belongs_to :payment, :index => true
    end
  end
end
