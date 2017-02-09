Rails.application.config.x.tenant = ENV['PROFILE'];
#
## Theme
#
Rails.application.config.x.theme.name       = ENV['PROFILE'];
Rails.application.config.x.theme.logo       = 'acme_logo_sm.png';
#
## Identity
#
Rails.application.config.x.company.name         = 'Acme'
Rails.application.config.x.company.address      = 'Address'
Rails.application.config.x.company.phone        = '(xxx) xxx-xxxx'
Rails.application.config.x.company.email        = 'info@fractel.com'
Rails.application.config.x.company.website_name = 'www.fractel.com'
Rails.application.config.x.company.website_url  = 'http://www.fractel.com'
Rails.application.config.x.company.motto        = 'Acme'
#
## Email
#
Rails.application.config.x.email.logo                 = ''
Rails.application.config.x.email.no_reply             = 'no-reply@fractel.com'
Rails.application.config.x.email.proposal_subject     = 'Acme Proposal'
Rails.application.config.x.email.proposal_replies     = 'sales@fractel.com'
Rails.application.config.x.email.invoice_sender       = 'billing@fractel.com'
Rails.application.config.x.email.invoice_subject      = 'Acme Invoice'
Rails.application.config.x.email.new_account_sender   = 'onboarding@fractel.com'
Rails.application.config.x.email.new_account_subject  = 'Your new Acme account is ready to use'
Rails.application.config.x.email.new_customer_subject = 'New Acme Account'
#
## Proposals
#
Rails.application.config.x.proposals.back_cover = "#{Rails.root}/public/docs/datasheets/proposal_back_cover.pdf"
Rails.application.config.x.proposals.terms = "#{Rails.root}/public/docs/datasheets/proposal_terms.pdf"
#
## Products
#
Rails.application.config.x.products.special_products = {
  :cloud_pbx => 'CLOUD-PBX-01',
  :sip_trunk => 'SIP-TRUNK-01',
  :did       => ['ADDL-DIDS-01', 'DID-LOCAL-01', 'DID-TF-01', 'DID-INTL-01'],
  :did_price => ['ADDL-DIDS-01'],
  :fax       => 'ENT-FAX-01',
  :discount  => 'DISCOUNT-01',
  :sales_tax => 'TX-FL-GST-01',
  :shipping  => 'SHIPPING-01',
}
