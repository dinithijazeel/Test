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
## SureTax Tax Products
#
Rails.application.config.x.products.tax_products = { 
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
  
	# :000   =>  'TX-CIT-CLLRT-01',
	# :101   =>  'TX-CIT-CLRT-01',
	# :040   =>  'TX-CIT-CLST-01',
	# :109   =>  'TX-CIT-COST-01',
	# :110   =>  'TX-CIT-CST-01',
	# :126   =>  'TX-CIT-L911S-01',
	# :129   =>  'TX-CIT-LBAOT-01',
	# :142   =>  'TX-CIT-LCT-01',
	# :144   =>  'TX-CIT-LFA-01',
	# :149   =>  'TX-CIT-LFF-01',
	# :150   =>  'TX-CIT-LGRT-01',
	# :203   =>  'TX-CIT-LLT-01',
	# :224   =>  'TX-CIT-LRWF-01',
	# :237   =>  'TX-CIT-LUUT-01',
	# :060   =>  'TX-COU-COLRT-01',
	# :035   =>  'TX-COU-COLST-01',
	# :107   =>  'TX-COU-COST-01',
	# :108   =>  'TX-COU-CST-01',
	# :124   =>  'TX-COU-L911S-01',
	# :133   =>  'TX-COU-LCT-01',
	# :202   =>  'TX-COU-LLT-01',
	# :216   =>  'TX-COU-LRWF-01',
	# :233   =>  'TX-COU-LUUT-01',
	# :117   =>  'TX-FED-FET-01',
	# :119   =>  'TX-FED-FTF-01',
	# :120   =>  'TX-FED-FUSF-01',
	# :118   =>  'TX-FED-FUSFR-01',
	# :122   =>  'TX-FED-GST-01',
	# :533   =>  'TX-FED-VAT-01',
	# :051   =>  'TX-LOC-COLST-01',
	# :059   =>  'TX-LOC-CLST-01',
	# :111   =>  'TX-LOC-CST-01',
	# :127   =>  'TX-LOC-L911S-01',
	# :238   =>  'TX-LOC-LUUT-01',
	# :302   =>  'TX-LOC-MS1-01',
	# :305   =>  'TX-LOC-MS2-01',
	# :128   =>  'TX-RAG-L911S-01',
	# :418   =>  'TX-RAG-UDPTT-01',
	# :106   =>  'TX-STA-CRSS-01',
	# :123   =>  'TX-STA-L911S-01',
	# :204   =>  'TX-STA-LRWF-01',
	# :245   =>  'TX-STA-MS1-01',
	# :304   =>  'TX-STA-MS2-01',
	# :316   =>  'TX-STA-MS3-01',
	# :324   =>  'TX-STA-MS4-01',
	# :331   =>  'TX-STA-PC-01',
	# :333   =>  'TX-STA-PST-01',
	# :332   =>  'TX-STA-PUCF-01',
	# :336   =>  'TX-STA-S911T-01',
	# :337   =>  'TX-STA-SBOT-01',
	# :338   =>  'TX-STA-SCT-01',
	# :343   =>  'TX-STA-SET-01',
	# :347   =>  'TX-STA-SFF-01',
	# :348   =>  'TX-STA-SGRT-01',
	# :403   =>  'TX-STA-SIMF-01',
	# :405   =>  'TX-STA-SLRT-01',
	# :404   =>  'TX-STA-SLT-01',
	# :416   =>  'TX-STA-SST-01',
	# :417   =>  'TX-STA-SUT-01',
	# :433   =>  'TX-STA-ULTSS-01',
	# :5C2   =>  'TX-STA-USF-01' ,
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
Rails.application.config.x.suretax.validation_key = 'dddcaf33-15e1-49af-a304-465651f75247'
Rails.application.config.x.suretax.client_number = '000000870'