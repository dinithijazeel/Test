class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      #
      # Contact
      t.string  :type,            :index => true
      t.integer :customer_status, :default => 0, :index => true
      t.string  :contact_first,   :null => false, :index => true
      t.string  :contact_last,    :null => false, :index => true
      t.string  :company_name,    :null => false, :index => true
      t.string  :admin_email,     :index => true
      t.string  :phone,           :null => false
      #
      # Billing Information
      t.string  :billing_email, :null => false, :index => true
      t.integer :default_terms, :default => 0, :index => true
      #
      # Billing Address
      t.string :billing_street_1, :null => false
      t.string :billing_street_2, :null => false
      t.string :billing_city,     :null => false
      t.string :billing_state,    :null => false
      t.string :billing_zip,      :null => false
      t.string :billing_country,  :null => false
      #
      # Service Address
      t.boolean :use_billing_for_service, :default => true
      t.string  :service_street_1,        :null => false
      t.string  :service_street_2,        :null => false
      t.string  :service_city,            :null => false
      t.string  :service_state,           :null => false
      t.string  :service_zip,             :null => false
      t.string  :service_country,         :null => false
      #
      # Affiliate and discount
      t.string :affiliate_id,   :null => false
      t.string :discount_code,  :null => false
      #
      # Foreign Keys
      t.string :is_id,     :index => true
      t.string :portal_id, :index => true
      #
      # History
      t.belongs_to :creator,     :index => true
      t.belongs_to :last_editor, :index => true
      t.timestamps :null => false
    end
  end
end
