Rails.application.config.x.tenant = ENV['PROFILE'];
#
## Theme
#
Rails.application.config.x.theme.name       = ENV['PROFILE'];
Rails.application.config.x.theme.logo       = 'fractel_logo_sm.png';
#
## Identity
#
Rails.application.config.x.company.name         = 'FracTEL LLC'
Rails.application.config.x.company.address      = '122 4th Ave. &bull; Ste. 201 &bull; Indialantic, Florida 32903 &bull; United States'
Rails.application.config.x.company.phone        = '(321) 499-1000'
Rails.application.config.x.company.email        = 'info@fractel.net'
Rails.application.config.x.company.website_name = 'www.fractel.net'
Rails.application.config.x.company.website_url  = 'https://www.fractel.net'
Rails.application.config.x.company.motto        = 'FracTEL LLC - Telecom Perfected'
#
## Email
#
Rails.application.config.x.email.logo                 = 'https://d1yoaun8syyxxt.cloudfront.net/kt192-bf46c636-99bb-4d38-b9d7-c844475ae780-v2'
Rails.application.config.x.email.no_reply             = 'no-reply@fractel.net'
Rails.application.config.x.email.proposal_subject     = 'FracTEL Cloud Communications Proposal'
Rails.application.config.x.email.proposal_replies     = 'sales@fractel.net'
Rails.application.config.x.email.invoice_sender       = 'billing@fractel.net'
Rails.application.config.x.email.invoice_subject      = 'FracTEL Invoice'
Rails.application.config.x.email.welcome_sender       = 'mike@fractel.net'
Rails.application.config.x.email.welcome_subject      = 'Welcome to FracTEL'
Rails.application.config.x.email.onboarding_questionnaire = "#{Rails.root}/public/docs/onboarding/questionnaire.pdf"
Rails.application.config.x.email.new_account_sender   = 'onboarding@fractel.net'
Rails.application.config.x.email.new_account_subject  = 'Your new FracTEL account is ready to use'
Rails.application.config.x.email.new_customer_subject = 'New FracTEL Account'
Rails.application.config.x.email.payment_sender       = 'billing@fractel.net'
Rails.application.config.x.email.payment_subject      = 'FracTEL Payment Received'
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
#
## Portl Integration
#
Rails.application.config.x.portal.billing_endpoint = 'https://billing.fractel.net/cgi-bin/portal/fractelportal.cgi'
#
## SureTax Integration
#
Rails.application.config.x.suretax.url = 'https://testapi.taxrating.net/Services/Communications/V01/SureTax.asmx'
Rails.application.config.x.suretax.api_key = 'dddcaf33-15e1-49af-a304-465651f75247'