# myriander

## Version 1.2.5

_released March 3, 2017_

### View Sorting

- Invoices and Proposals are now sorted in reverse chronological order by default
- The proposal, invoice, payment, and credit sections of the customer card are also in reverse chronological order

### Payments

- Instead of prompting for a payment type, the payment dialog now prompts for a payment account
  - Stripe
  - SCCU
  - Chase
  - Wells Fargo
  - Intuit
  - Credit

### Customers

- Customer cards now have an activity statement at the top
  - Previous balance
  - Payments received
  - Adjustments
  - Current charges
  - Balance due

## Version 1.2.4

_released February 26, 2017_

### Contacts

- Added `myriander:refresh_contacts` task to refresh all contacts with a `portal_id` from Portal

### Table Sorting

- Added tablesorter.js library to assets
- Configured main listings to be sortable
- Added code to allow sorting by last name (in full name columns) and amount (in fields with money amounts)

### Staging

- Improve email interception
  - Remove email CC when staging
  - BCC myriander@fractel.net otherwise

### AxeCom Provisioning

- Organize templates with inheritance
- Generate AxeCom graphics
- Update proposals
- Update invoice
- Update emails
- Disable Portal account creation
- Disable customer payments

### SureTax Integration

- Added `tax_exemption_certificate` to contacts
  - Reading in `tax_exemption_certificate` from Portal
- Added `sure_tax_code` to products
  - Updated `sure_tax_code` from data provided by SureTax
- Added `billing_start` and `billing_end` to service invoices
  - Reading in values from Portal's service invoice JSON
  - Updated past invoices manually

## Version 1.2.3

_released February 19, 2017_

### Service Invoices

- Contact information from incoming Portal invoices is read and used to update Myriander contact data

### Contacts

- Contacts with portal accounts are no longer editable in Myriander; their information needs to be edited in Portal.
- Added API endpoint for Portal to use for updating Myriander data
- Remove code to update accounts in Portal when a record is edited in Myriander
- Leads from 360 Connect are being automatically scanned into Myriander
  - Leads with duplicate email addresses have their comments appended to the original record
  - leads@fractel.net is scanned every two minutes
- The Contacts index is now broken in two sections
  -  `Leads` (showing records in the `Lead` category updated in the last week)
  -  `Contacts` (showing all other contacts, updated in the last month)

### Email

- Invoice and Payment emails are now cc'd to `accounting@fractel.net`
- Emails generated on the staging server (dev-myr.fractel.net) are now intercepted
  - Sent to `myriander@fractel.net` instead of intended recipient
  - `TEST` is prepended to the message subject

### Products

- Expose Vendor SKU for editing
- Fix update error when saving edited products

### Payments

- A payment can be entered for an invoice by clicking on the payment amount
- A payment spanning multiple invoices can be added for a customer by clicking on the `+` on top of their payments list
- A credit can be issued for a customer by clicking on the `+` on top of their credits list
- A standalone payment system to replace myr.fractel.net payments is in place
- A standalone payment system for prepaid payments is in place
  - Invoices for payment amount are generated and sent

### Invoices

- Paid invoice PDFs have a `PAID` stamp added
- Invoice payment links go to new standalone payment system (not the Portal merry-go-round)
