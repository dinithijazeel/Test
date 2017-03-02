class LoosenContacts < ActiveRecord::Migration
  def up
    change_column_null :contacts, :contact_first, true
    change_column_null :contacts, :contact_last, true
    change_column_null :contacts, :company_name, true
    change_column_null :contacts, :admin_email, true
    change_column_null :contacts, :phone, true
    change_column_null :contacts, :billing_email, true
    change_column_null :contacts, :billing_street_1, true
    change_column_null :contacts, :billing_street_2, true
    change_column_null :contacts, :billing_city, true
    change_column_null :contacts, :billing_state, true
    change_column_null :contacts, :billing_zip, true
    change_column_null :contacts, :billing_country, true
    change_column_null :contacts, :service_street_1, true
    change_column_null :contacts, :service_street_2, true
    change_column_null :contacts, :service_city, true
    change_column_null :contacts, :service_state, true
    change_column_null :contacts, :service_zip, true
    change_column_null :contacts, :service_country, true
    change_column_null :contacts, :affiliate_id, true
    change_column_null :contacts, :discount_code, true
  end
  def down
    change_column_null :contacts, :contact_first, false
    change_column_null :contacts, :contact_last, false
    change_column_null :contacts, :company_name, false
    change_column_null :contacts, :admin_email, false
    change_column_null :contacts, :phone, false
    change_column_null :contacts, :billing_email, false
    change_column_null :contacts, :billing_street_1, false
    change_column_null :contacts, :billing_street_2, false
    change_column_null :contacts, :billing_city, false
    change_column_null :contacts, :billing_state, false
    change_column_null :contacts, :billing_zip, false
    change_column_null :contacts, :billing_country, false
    change_column_null :contacts, :service_street_1, false
    change_column_null :contacts, :service_street_2, false
    change_column_null :contacts, :service_city, false
    change_column_null :contacts, :service_state, false
    change_column_null :contacts, :service_zip, false
    change_column_null :contacts, :service_country, false
    change_column_null :contacts, :affiliate_id, false
    change_column_null :contacts, :discount_code, false
  end
end
