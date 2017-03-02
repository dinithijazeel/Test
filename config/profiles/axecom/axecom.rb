Rails.application.config.x.tenant = ENV['PROFILE'];
#
## Theme
#
Rails.application.config.x.theme.name       = ENV['PROFILE'];
Rails.application.config.x.theme.logo       = 'axecom_logo_sm.png';
#
## Identity
#
Rails.application.config.x.company.name         = 'AxeCom'
Rails.application.config.x.company.address      = '122 4th Ave. &bull; Ste. 201 &bull; Indialantic, Florida 32903 &bull; United States'
Rails.application.config.x.company.street       = '122 4th Ave., Ste. 201'
Rails.application.config.x.company.city_st_zip  = 'Indialantic, Florida 32903'
Rails.application.config.x.company.phone        = '(844) 4AXECOM'
Rails.application.config.x.company.email        = 'info@4axecom.com'
Rails.application.config.x.company.accounting_phone = '(904) 555-1212'
Rails.application.config.x.company.accounting_email = 'accounting@4axecom.com'
Rails.application.config.x.company.website_name = 'www.4axecom.com'
Rails.application.config.x.company.website_url  = 'https://www.4axecom.com'
Rails.application.config.x.company.motto        = 'Axecom'
#
## Operation
#
# Rails.application.config.x.features.fractel_onboarding   = true
#
#
## Email
#
Rails.application.config.x.email.logo                 = 'https://axecom.fractel.net/wp-content/themes/logo_md.png'
Rails.application.config.x.email.no_reply             = 'no-reply@4axecom.com'
Rails.application.config.x.email.proposal_subject     = 'AxeCom Proposal'
Rails.application.config.x.email.proposal_replies     = 'sales@4axecom.com'
Rails.application.config.x.email.invoice_sender       = 'billing@4axecom.com'
Rails.application.config.x.email.invoice_subject      = 'AxeCom Invoice'
Rails.application.config.x.email.welcome_sender       = 'mike@4axecom.com'
Rails.application.config.x.email.welcome_subject      = 'Welcome to AxeCom'
Rails.application.config.x.email.new_account_sender   = 'onboarding@4axecom.com'
Rails.application.config.x.email.new_account_subject  = 'Your new AxeCom account is ready to use'
Rails.application.config.x.email.new_customer_subject = 'New AxeCom Account'
Rails.application.config.x.email.payment_sender       = Rails.application.config.x.company.accounting_email
Rails.application.config.x.email.payment_subject      = 'AxeCom Payment Received'
Rails.application.config.x.email.staging_email        = 'myriander@fractel.net'
Rails.application.config.x.email.accounting_email     = Rails.application.config.x.company.accounting_email
#
## Proposals
#
Rails.application.config.x.proposals.back_cover = "#{Rails.root}/public/docs/datasheets/proposal_back_cover.pdf"
Rails.application.config.x.proposals.terms = "#{Rails.root}/public/docs/datasheets/proposal_terms.pdf"
#
## Products
#
Rails.application.config.x.products.special_products = {
  :cloud_pbx   => 'CLOUD-PBX-01',
  :sip_trunk   => 'SIP-TRUNK-01',
  :did         => ['ADDL-DIDS-01', 'DID-LOCAL-01', 'DID-TF-01', 'DID-INTL-01'],
  :did_price   => ['ADDL-DIDS-01'],
  :fax         => 'ENT-FAX-01',
  :discount    => 'DISCOUNT-01',
  :sales_tax   => 'TX-FL-GST-01',
  :federal_tax => 'TX-FUSF-01',
  :state_tax   => 'TX-FL-CST-01',
  :local_tax   => 'TX-LOC-CST-01',
  :shipping    => 'SHIPPING-01',
  :prepaid     => 'PREPAID-01',
}
#
## Freshdesk Integration
#
Rails.application.config.x.freshdesk.url = 'https://fractel.freshdesk.com/'
Rails.application.config.x.freshdesk.api_key = '3oFZAyvGj90FTEyTHh'
Rails.application.config.x.freshdesk.onboarding_subject = 'Onboarding Request'
Rails.application.config.x.freshdesk.onboarding_description = 'Onboarding Request'
Rails.application.config.x.freshdesk.groups_onboarding = 14000107507
