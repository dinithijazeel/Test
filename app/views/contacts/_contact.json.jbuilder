json.extract! contact, :id, :contact_first, :contact_last, :company_name, :admin_email, :billing_email, :billing_street_1, :billing_street_2, :billing_city, :billing_state, :billing_zip, :billing_country, :service_street_1, :service_street_2, :service_city, :service_state, :service_zip, :service_country, :default_terms
json.phone phone(contact.phone)
json.billing_address contact.billing_address
json.service_address contact.service_address
json.url contact_url(contact, format: :json)
