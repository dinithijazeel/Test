class ServiceInvoice < Invoice
  #
  ## API
  #
  def self.parse_portal(json_invoice)
    json_invoice = json_invoice[0]
    invoice = self.new
    billing_info = {}
    billing_code = nil
    total = nil
    json_invoice.each_pair do |name, value|
      case name
      when 'BillingCode'
        billing_code = value[0]
      when 'BillTo'
        billing_info = value[0]
        billing_info = {
          company_name: billing_info['Name'][0],
          contact_first: billing_info['FirstName'][0],
          contact_last: billing_info['LastName'][0],
          billing_email: billing_info['Email'][0],
          billing_street_1: billing_info['Addr1'][0],
          billing_street_2: billing_info['Addr2'][0],
          billing_city: billing_info['City'][0],
          billing_state: billing_info['State'][0],
          billing_zip: billing_info['Zip'][0],
          phone: billing_info['Phone'][0],
        }
        # print "#{billing_info}\n"
      when 'InvoiceDate'
        invoice.invoice_date = value[0]
      when 'InvoiceStatus'
        case value[0]
        when 'draft'
          invoice.invoice_status = Invoice.invoice_statuses[:draft]
        else
          invoice.invoice_status = Invoice.invoice_statuses[:open]
        end
      when 'InvoiceNumber'
        invoice.number = value[0]
      when 'InvoiceID'
        invoice.portal_id = value[0]
      when 'CDRUrl'
        invoice.cdr_url = value[0]
      when 'DIDUrl'
        invoice.did_url = value[0]
      when 'TotalAmountDue'
        total = value[0].to_f
      when 'LineItems'
        value.each do |line_item|
          # Only return non-zero line items
          if line_item['TotalPrice'][0].to_f != 0
            product_id = nil
            description = line_item['Description'][0]
            # Try a straight match first
            product = Product.find_by(vendor_sku: description)
            # If not found, build SKU word by word
            if product.nil?
              partial_description = ''
              words = description.split
              words.each do |word|
                partial_description = "#{partial_description} #{word}"
                product = Product.find_by(vendor_sku: partial_description.strip)
                break unless product.nil?
              end
            end
            # Error reporting
            if product.nil?
              invoice.errors.add(:errors, "Unknown product: #{description}")
            else
              # Build line item
              invoice.line_items.build(
                :unit_price  => line_item['TotalPrice'][0].to_f / line_item['Quantity'][0].to_f,
                :quantity    => line_item['Quantity'][0].to_f,
                :description => description,
                :product_id  => product.id,
              )
            end
          end
        end
      else
        # print "#{name}\n"
      end
    end
    # Fill out memo and remove nil line items
    invoice.memo = "Service Invoice for #{invoice.invoice_date}"
    # Fill out contact from billing code
    unless billing_code.nil?
      customer = Contact.find_by(:portal_id => billing_code)
      if customer.nil?
        invoice.errors.add(:errors, "Unknown customer account: #{billing_code}")
      else
        customer.update_columns(billing_info)
        invoice.contact = customer
        invoice.terms = customer.default_terms
      end
    end
    # Make sure our totals add up
    if total != invoice.invoice_total
      invoice.errors.add(:errors, "Mismatched totals: #{total} (Portal) / #{invoice.invoice_total} (Myr)")
    end
    # Return invoice
    invoice
  end
  #
  ## PDF Rendering Helpers
  #
  def additional_pages
    per_page = 15
    pages = []
    current_page = []
    current_page_count = 0
    billing_groups.each do |group|
      if current_page_count + group[:line_items].count <= per_page
        current_page << group
      else
        pages << current_page
        current_page = [group]
      end
      current_page_count += group[:line_items].count
    end
    pages << current_page
  end

  def billing_groups(groups = false)
    # Set default groups
    groups = groups || [:recurring, :usage, :non_recurring, :taxes]
    # Handle single item groups
    if groups.is_a? Symbol
      groups = [groups]
    end
    # Collect groups
    groups = groups.collect do |billing_type|
      billing_label = I18n.t :"activerecord.attributes.product.billings.#{billing_type}"
      billing_items = line_items.billing_type(billing_type)
      subtotal = LineItem.sum(:total, line_items.billing_type(billing_type))
      {
        :type => billing_label,
        :line_items => billing_items,
        :subtotal => subtotal,
        :hide_quantity => [:taxes].include?(billing_type),
      }
    end
    # If it's only one, return as a listing (not an array of one)
    if groups.count == 1
      groups[0]
    else
      groups
    end
  end

  def pdf_template
    "tenants/#{Rails.application.config.x.tenant}/invoices/service_pdf.html.slim"
  end
end
