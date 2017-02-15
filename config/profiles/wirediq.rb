Rails.application.config.x.tenant = ENV['PROFILE'];
#
## Theme
#
Rails.application.config.x.theme.name       = ENV['PROFILE'];
Rails.application.config.x.theme.logo       = 'wirediq_logo_sm.png';
#
## Identity
#
Rails.application.config.x.company.name         = 'WiredIQ'
Rails.application.config.x.company.address      = 'Address'
Rails.application.config.x.company.phone        = '(xxx) xxx-xxxx'
Rails.application.config.x.company.email        = 'info@wirediq.com'
Rails.application.config.x.company.website_name = 'www.wirediq.com'
Rails.application.config.x.company.website_url  = 'http://www.wirediq.com'
Rails.application.config.x.company.motto        = 'WiredIQ'
#
## Email
#
Rails.application.config.x.email.logo                 = ''
Rails.application.config.x.email.no_reply             = 'no-reply@wirediq.com'
Rails.application.config.x.email.proposal_subject     = 'WiredIQ Proposal'
Rails.application.config.x.email.proposal_replies     = 'sales@wirediq.com'
Rails.application.config.x.email.invoice_sender       = 'billing@wirediq.com'
Rails.application.config.x.email.invoice_subject      = 'WiredIQ Invoice'
Rails.application.config.x.email.new_account_sender   = 'onboarding@wirediq.com'
Rails.application.config.x.email.new_account_subject  = 'Your new WiredIQ account is ready to use'
Rails.application.config.x.email.new_customer_subject = 'New WiredIQ Account'
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
  :cloud_pbx => 'CLOUD-PBX-01',
  :sip_trunk => 'SIP-TRUNK-01',
  :did       => ['ADDL-DIDS-01', 'DID-LOCAL-01', 'DID-TF-01', 'DID-INTL-01'],
  :did_price => ['ADDL-DIDS-01'],
  :fax       => 'ENT-FAX-01',
  :discount  => 'DISCOUNT-01',
  :sales_tax => 'TX-FL-GST-01',
  :shipping  => 'SHIPPING-01',
}
