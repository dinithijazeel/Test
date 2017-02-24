class Bom < ActiveRecord::Base
  #
  ## Behavior
  #
  acts_as_paranoid
  acts_as_commentable
  #
  ## Associations
  #
  belongs_to :contact
  has_many   :line_items
  accepts_nested_attributes_for :line_items, :reject_if => :all_blank, :allow_destroy => true
  belongs_to :creator,     :class_name => 'User'
  belongs_to :last_editor, :class_name => 'User'
  #
  ## Enumeration
  #
  enum :invoice_status => [:draft, :open, :paid, :closed, :credit, :canceled, :obsolete]
  enum :rating_status  => [:rating_pending, :rating_processed, :rating_error]
  enum :terms          => [:net10, :net30, :due, :special_terms]
  #
  ## Validation
  #
  validates :invoice_date, :presence => true
  validates :contact_id, :presence => { :message => 'Company can\'t be blank' }, :on => :update
  #
  ## Scopes
  #
  scope :open_invoices_for, -> (contact_id) {
    where(invoice_status: Invoice.invoice_statuses[:open], contact_id: contact_id).
    where('boms.type IN (\'Invoice\',\'ServiceInvoice\')')
  }
  scope :invoices_updated_this_month, -> {
    where(updated_at: 4.weeks.ago..Time.now).
    where('boms.type IN (\'Invoice\',\'ServiceInvoice\')')
  }

  # Callbacks

  before_create do
    self.creator = User.current || User.find(1)
  end

  before_update do
    self.last_editor = User.current || User.find(1)
  end

  before_save do
    update_rating
    set_invoice_total
    if invoice_status == 'open'
      # Make sure open invoices have a token, date, and number
      self.payment_token = SecureRandom.uuid if payment_token.blank?
      self.invoice_date = Time.now if invoice_date.blank?
      self.number = generate_number if number.blank?
    end
  end

  # Listings

  def self.index
    Invoice.order(:invoice_date => :desc).all
  end

  def self.draft_invoices
    Invoice.where(:invoice_status => Invoice.invoice_statuses[:draft]).all
  end

  def self.open_invoices
    Invoice.where(:invoice_status => Invoice.invoice_statuses[:open]).all
  end

  def self.paid_invoices
    Invoice.where(:invoice_status => Invoice.invoice_statuses[:paid]).all
  end

  def self.closed_invoices
    Invoice.where(:invoice_status => Invoice.invoice_statuses[:closed]).all
  end

  # Helpers

  def generate_number
    self.number = invoice_date.to_s(:number)[2..-1]
    latest = Invoice.where('number LIKE ?', "#{number}%").order('number DESC').first
    if latest.nil?
      self.number += '0001'
    else
      self.number = latest.number.succ
    end
  end

  def generate_pdf
    pdf = Pdf.generate(pdf_template, instance_vars: {pdf_invoice: self})
    update_attribute(:pdf, File.open(pdf))
  end

  def send_invoice_later(sender_id = nil)
    # Use current user if we don't specify a sender
    sender_id = User.current.id if sender_id.nil?
    # Queue for execution
    # SendInvoiceJob.perform_later(self.id, sender_id)
  end

  def send_invoice(sender_id = nil)
    # Use current user if we don't specify a sender
    sender_id = User.current.id if sender_id.nil?
    # Recast to use proper templates
    pdf_invoice = self.becomes(self.type.constantize)
    # Generate PDF if necessary
    pdf_invoice.generate_pdf
    # Send mail
    InvoiceMailer.invoice(pdf_invoice).deliver_now
    # Log activity
    message = "Invoice #{number} sent to #{contact.invoice_email}"
    Comment.build_from(contact, sender_id, message).save
  end

  def has_line_item(product)
    !filtered_line_items(product).empty?
  end

  def filtered_line_items(filter)
    # Get SKU
    product_sku = Rails.application.config.x.products.special_products[filter]
    # Normalize to array
    unless product_sku.is_a?(Array)
      product_sku = [product_sku]
    end
    # Filter line items
    line_items.select { |li| product_sku.include? li.product.sku }
  end

  def payable_amount
    total_due
  end

  def payable_name
    contact.company_name
  end

  def update_rating
    # Get existing tax items
    old_tax_items = line_items.joins(:product).where(products: {product_type: Product.product_types[:tax]})
    line_items.destroy(old_tax_items) unless old_tax_items.empty?
    # Calculate new line items
    new_tax_items = get_rating_line_items
    # Add to line items
    line_items << new_tax_items
    # Timestamp rating
    self.rated_at = Time.now
    self.rating_status = :rating_processed
  end

  def get_rating_line_items
	url  =  "#{Rails.application.config.x.suretax.url}/PostRequest"  
	api_key = Rails.application.config.x.suretax.api_key 
  
    #generate number if blank
	self.number = generate_number if number.blank?
	
    #generate line items hash
	line_item_hash = Hash.new()  
	line_item_array = [] 
	i = 1
	# line_items.each do |line_item| 
		# line_item_hash ={:LineNumber => i,
									# :InvoiceNumber => number,
									# :CustomerNumber => contact.portal_id,
									# :OrigNumber =>'',#?  Optional fields
									# :TermNumber => '',#?  Optional fields
									# :BillToNumber => '',#?  Optional fields  
									# :TransDate => invoice_date.strftime("%m/%d/%Y")  ,
									# :BillingPeriodStartDate => '', #?
									# :BillingPeriodEndDate => '',#?
									# :Revenue => line_item.total.to_s,
									# :Units => line_item.quantity.to_i.to_s,   
									# :UnitType => '00',
									# :Seconds => line_item.product.billing =='usage' ? line_item.quantity.to_i.to_s : '1',  
									# :TaxIncludedCode => '0',
									# :TaxSitusRule => '04',
									# :TransTypeCode => '050101', #? This field does not exist yet, it needs to be added
									# :SalesTypeCode => 'B',  # (B for everyone)
									# :RegulatoryCode => '03', # 03 -> VOIP, recommended by CCH
									# :TaxExemptionCodeList => [''], #? Need clarification from CCH on this.  
									# :ExemptReasonCode => 'None', #?Need clarification from CCH on this.  
									# # :CostCenter => '', #?  Optional fields
									# # :GLAccount => '', #?  Optional fields
									# # :MaterialGroup => '', #?  Optional fields
									# # :CurrencyCode => '', #?  Optional fields
									# # :OriginCountryCode => '', #?  Optional fields
									# # :DestCountryCode => '', #?  Optional fields
									# :BillingDaysInPeriod => 0,#?
									# :Parameter1 => line_item.product.sku,  
									# :Parameter2 => line_item.product.name,  
									# :Parameter3 => line_item.unit_price.to_s,  
									# :Parameter4 => line_item.quantity.to_s,  
									# :Parameter5 => line_item.total.to_s,  
									# # :Parameter6 => '', #?  Optional fields
									# # :Parameter7 => '', #?  Optional fields
									# # :Parameter8 => '', #?  Optional fields
									# # :Parameter9 => '', #?  Optional fields
									# # :Parameter10 => '', #?  Optional fields
									# # :UDF => '', #?  Optional fields
									# # :UDF2 => '', #?  Optional fields
									# :Address => {:PrimaryAddressLine => '',
												# :SecondaryAddressLine => '',
												# :County => '', 
												# :City => '',
												# :State => '',
												# :PostalCode => contact.service_zip,
												# :Plus4 => '',
												# :Country =>  contact.service_country =='Canada' ? 'CA' : 'US',
												# :Geocode => '',
												# :VerifyAddress => '0'},
									# :P2PAddress => {:PrimaryAddressLine => '',
													# :SecondaryAddressLine => '',
													# :County => '',
													# :City => '',
													# :State => '',
													# :PostalCode => '',
													# :Plus4 => '',
													# :Country => '',
													# :Geocode => '',
													# :VerifyAddress => 'false'}  
								 
						# }  
	    # line_item_array.push(line_item_hash)
		# i += 1
    # end   
  
    # #generate main hash for SureTax API call 
	# main_hash = {:ClientNumber => '000000870',
		# :BusinessUnit => Rails.application.config.x.tenant,  
		# :ValidationKey => api_key,
		# :DataYear =>  invoice_date.strftime("%Y"),
		# :DataMonth =>  invoice_date.strftime("%m"),
		# :CmplDataYear => invoice_date.strftime("%Y"),  
		# :CmplDataMonth =>  invoice_date.strftime("%m"),  
		# :TotalRevenue => invoice_total.to_s,
		# :ReturnFileCode => invoice_status=='open' ? '0' : 'Q',  
		# :ClientTracking => contact.portal_id ,
		# :ResponseGroup => '00',
		# :ResponseType => 'D2',  
		# :STAN => number.split(//).last(4).join("").to_s + '-' + Time.now.to_i.to_s, 
		# :ItemList => line_item_array
	# } 
	
	
	line_items.each do |line_item| 
		line_item_hash ={:LineNumber => i,
									:InvoiceNumber => number,
									:CustomerNumber => contact.portal_id,
									:OrigNumber =>'',#?  Optional fields
									:TermNumber => '',#?  Optional fields
									:BillToNumber => '',#?  Optional fields  
									:TransDate => invoice_date.strftime("%m/%d/%Y")  ,
									:BillingPeriodStartDate => '', #?
									:BillingPeriodEndDate => '',#?
									:Revenue => line_item.total.to_s,
									:Units => line_item.quantity.to_i.to_s,   
									:UnitType => '00',
									:Seconds => line_item.product.billing =='usage' ? line_item.quantity.to_i.to_s : '1',  
									:TaxIncludedCode => '0',
									:TaxSitusRule => '04',
									:TransTypeCode => '050101', #? This field does not exist yet, it needs to be added
									:SalesTypeCode => 'B',  # (B for everyone)
									:RegulatoryCode => '03', # 03 -> VOIP, recommended by CCH
									:TaxExemptionCodeList => [''], #? Need clarification from CCH on this.  
									:ExemptReasonCode => 'None', #?Need clarification from CCH on this.  
									# :CostCenter => '', #?  Optional fields
									# :GLAccount => '', #?  Optional fields
									# :MaterialGroup => '', #?  Optional fields
									# :CurrencyCode => '', #?  Optional fields
									# :OriginCountryCode => '', #?  Optional fields
									# :DestCountryCode => '', #?  Optional fields
									:BillingDaysInPeriod => '0',#?
									:Parameter1 => line_item.product.sku,  
									:Parameter2 => line_item.product.name,  
									:Parameter3 => line_item.unit_price.to_s,  
									:Parameter4 => line_item.quantity.to_s,  
									:Parameter5 => line_item.total.to_s,  
									# :Parameter6 => '', #?  Optional fields
									# :Parameter7 => '', #?  Optional fields
									# :Parameter8 => '', #?  Optional fields
									# :Parameter9 => '', #?  Optional fields
									# :Parameter10 => '', #?  Optional fields
									# :UDF => '', #?  Optional fields
									# :UDF2 => '', #?  Optional fields
									:Address => {:PrimaryAddressLine => '',
												:SecondaryAddressLine => '',
												:County => '', 
												:City => '',
												:State => '',
												:PostalCode =>   contact.service_zip,
												:Plus4 => '',
												:Country =>  contact.service_country =='Canada' ? 'CA' : 'US',
												:Geocode => '',
												:VerifyAddress => '0'},
									:P2PAddress => {:PrimaryAddressLine => '',
													:SecondaryAddressLine => '',
													:County => '',
													:City => '',
													:State => '',
													:PostalCode => '',
													:Plus4 => '',
													:Country => '',
													:Geocode => '',
													:VerifyAddress => 'false'}  
								 
						}  
	    line_item_array.push(line_item_hash)
		i += 1
    end   
  
    #generate main hash for SureTax API call 
	main_hash = {:ClientNumber => '000000870',
		:BusinessUnit => Rails.application.config.x.tenant,  
		:ValidationKey => api_key,
		:DataYear =>  invoice_date.strftime("%Y"),
		:DataMonth =>  invoice_date.strftime("%m"),
		:CmplDataYear => invoice_date.strftime("%Y"),  
		:CmplDataMonth =>  invoice_date.strftime("%m"),  
		:TotalRevenue => invoice_total.to_s,
		:ReturnFileCode => invoice_status=='open' ? '0' : 'Q',  
		:ClientTracking => contact.portal_id ,
		:ResponseGroup => '00',
		:ResponseType => 'D2',  
		:STAN => number.split(//).last(4).join("").to_s + '-' + Time.now.to_i.to_s, 
		:ItemList => line_item_array
	} 
	
	  puts "%%%%%%%%%%%%%%%%%%%%%%%333333333"
	  puts main_hash.to_json
	  puts "%%%%%%%%%%%%%%%%%%%%%%%33333333333" 

	#Add request wrapper to json data
	json_text = {:request => main_hash.to_json}.to_json  
	 
	#Calling SureTax API 
	site = RestClient::Resource.new(url) 
    begin 
		response = site.post(json_text ,:content_type=>'application/json');
		 
		parsed= JSON.parse(JSON.parse(response.body)["d"])
		if parsed["Successful"] =='Y' && parsed["ResponseCode"] =='9999'  
			new_line_item_array =  []   
			parsed["GroupList"].each do |group| 
				group["TaxList"].each do |tax|
					puts tax["TaxTypeCode"]
					puts tax["TaxTypeDesc"]

					p = LineItem.new(
						  description: tax["TaxTypeDesc"],
						  quantity: 1,
						  unit_price: tax["TaxRate"],  
						  product:  Product.find_by_sku("GS-GXP2160-01"))  
					new_line_item_array.push(p) 
				end
			end
		else
		puts"???????????????????????????????????????????????????????????????"
		
			# Handle if SureTax API return any errors
			puts 'API Error: Your request is not successful.' 
			puts "Transaction ID: #{parsed["TransId"]}" 
			puts "Response Code: #{parsed["ResponseCode"]} Header Message: #{parsed["HeaderMessage"]}" 
			if parsed["ResponseCode"] =='9001' # have item errors 
				parsed["ItemMessages"].each do |itemmsg|  
					puts "LineNumber: #{itemmsg["LineNumber"]} Response Code:#{itemmsg["ResponseCode"]} Message:#{itemmsg["Message"]} "  
				end  
			end
		end 
	  
    rescue RestClient::Exception => exception
	  puts 'API Error: Your request is not successful.'  
      puts "X-Request-Id: #{exception.response.headers[:x_request_id]}"
      puts "Response Code: #{exception.response.code} \nResponse Body: #{exception.response.body} \n"
    end
	
  
    # Calculate taxes
    federal_tax_amount = invoice_total * 0.12
    state_tax_amount = invoice_total * 0.05
    local_tax_amount = invoice_total * 0.06
    # Get products from sku's
    federal_tax_product = Product.find_by_sku(Rails.application.config.x.products.special_products[:federal_tax])
    state_tax_product = Product.find_by_sku(Rails.application.config.x.products.special_products[:state_tax])
    local_tax_product = Product.find_by_sku(Rails.application.config.x.products.special_products[:local_tax])
    # Create array of line items to return
    [
      LineItem.new(
        description: federal_tax_product.description,
        quantity: 1,
        unit_price: federal_tax_amount,
        product: federal_tax_product
      ),
      LineItem.new(
        description: state_tax_product.description,
        quantity: 1,
        unit_price: state_tax_amount,
        product: state_tax_product
      ),
      LineItem.new(
        description: local_tax_product.description,
        quantity: 1,
        unit_price: local_tax_amount,
        product: local_tax_product
      ),
    ]
  end

  # View Helpers

  def invoice_status_label
    I18n.t :"activerecord.attributes.invoice.invoice_statuses.#{invoice_status}"
  end

  def rating_status_label
    I18n.t :"activerecord.attributes.invoice.rating_statuses.#{rating_status}"
  end

  def terms_label
    I18n.t :"activerecord.attributes.invoice.terms.#{terms}"
  end

  def recalculate
    reload
    set_invoice_total
    save
  end

  def summary(divider = ' / ')
    names = []
    line_items.each do |line_item|
      # Make float into int if it's a whole number
      quantity = (line_item.quantity.to_i == line_item.quantity) ? line_item.quantity.to_i : line_item.quantity
      # Add to array
      names << "#{quantity} x #{line_item.product.name}"
    end
    names.join(divider)
  end

  def self.controller_params
    [ :number,
      :invoice_date,
      :terms,
      :invoice_total,
      :total_paid,
      :total_due,
      :payment_status,
      :description,
      :memo,
      :contact_id,
      :portal_id,
      :cdr_url,
      :did_url,
      :line_items_attributes => ([:id] + LineItem.controller_params) ]
  end

  def invoice_total
    # Calculate invoice total
    invoice_total = 0
    line_items.each do |line_item|
      invoice_total += (line_item.quantity * line_item.unit_price)
    end
    invoice_total.round(2)
  end

  # Privates!

  protected

  def set_invoice_total
    self.invoice_total = invoice_total
  end
end
