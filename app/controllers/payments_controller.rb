class PaymentsController < ApplicationController
  respond_to :html, :js
  before_action :set_payment, :only => [:show, :edit, :update, :destroy]

  def show
    render 'show', :layout => false
  end

  def edit
    # Add any open invoices
    payment_invoices.each do |invoice|
      print "ADD INVOICE #{invoice.id}\n"
      unless @payment.credits.exists?(:invoice_id => invoice.id)
        @payment.credits.build(:invoice => invoice)
      end
    end
    # Figure out the payment form to use
    if Payment.bank_deposits.include? @payment.payment_type
      @payment_type = 'Bank Deposit'
    elsif Payment.credits.include? @payment.payment_type
      @payment_type = 'Credit'
    else
      @payment_type = 'Stripe'
    end
  end

  def new
    # Load Tests
    @tests = PaymentsController.tests
    # Create new payment
    @payment = Payment.new
    # Create payment credits from invoices
    invoices = payment_invoices
    invoices.each do |invoice|
      @payment.credits.build(:invoice => invoice)
    end
    # Add date and amount to payment
    @payment.amount = @payment.invoice_total
    @payment.payment_date = Date.today
    # Figure out customer for payment
    @payment.customer_id = params[:customer_id] || invoices[0].contact_id
    # Create stripe transaction
    @payment.build_stripe_transaction
    # Show form
    render 'edit', :layout => false
  end

  def create
    # Load tests
    @tests = PaymentsController.tests
    # Build invoice and payment
    @payment = Payment.new(payment_params)
    # Respond
    if @payment.valid?
      # Attempt to run Stripe payments
      if @payment.payment_type == 'Stripe'
        success = process_stripe
      else
        success = true
      end
      # Continue processing if Stripe was good
      if success
        @payment.client_ip = request.remote_ip
        @payment.memo = "#{@payment.payment_type} - #{@payment.customer.company_name}" if @payment.memo.nil? || @payment.memo.empty?
        @payment.save
        Comment.build_from(@payment.customer, current_user.id, "Payment received: $ #{format("%#.2f", @payment.amount)} (#{@payment.payment_type})").save
        respond_to do |format|
          format.js { helper_reload }
        end
      end
    else
      print "\n\n\nERRORS: #{@payment.errors.inspect}\n\n\n"
      @invoices = payment_invoices
      respond_to do |format|
        format.js { render :edit }
      end
    end
  end

  def update
    # Load tests
    @tests = PaymentsController.tests
    # Update payment attributes
    @payment.attributes = payment_params
    # Respond
    if @payment.valid?
      # Attempt to run Stripe payments
      if @payment.payment_type == 'Stripe'
        success = process_stripe
      else
        success = true
      end
      # Continue processing if Stripe was good
      if success
        @payment.client_ip = request.remote_ip
        @payment.memo = "#{@payment.payment_type} - #{@payment.customer.company_name}" if @payment.memo.nil? || @payment.memo.empty?
        @payment.save
        Comment.build_from(@payment.customer, current_user.id, "Payment updated: $ #{format("%#.2f", @payment.amount)} (#{@payment.payment_type})").save
        respond_to do |format|
          format.js { helper_reload }
        end
      end
    else
      respond_to do |format|
        format.js { render :edit }
      end
    end
  end



  #
  ## Helpers
  #

  def self.tests
    {
      :VISA => {
        :'data-cc-number' => '4012888888881881',
        :'data-cc-expiration' => '05/2019',
        :'data-cc-cvc' => '564',
        # :'data-amount' => '300.00'
      },
      :'VISA Debit' => {
        :'data-cc-number' => '4000056655665556',
        :'data-cc-expiration' => '05/2019',
        :'data-cc-cvc' => '564',
        # :'data-amount' => '300.00'
      },
      :MasterCard => {
        :'data-cc-number' => '5555555555554444',
        :'data-cc-expiration' => '05/2019',
        :'data-cc-cvc' => '564',
        # :'data-amount' => '300.00'
      },
      :'MasterCard Debit' => {
        :'data-cc-number' => '5200828282828210',
        :'data-cc-expiration' => '05/2019',
        :'data-cc-cvc' => '564',
        # :'data-amount' => '300.00'
      },
      :'American Express' => {
        :'data-cc-number' => '378282246310005',
        :'data-cc-expiration' => '05/2019',
        :'data-cc-cvc' => '564',
        # :'data-amount' => '300.00'
      },
      :Discover => {
        :'data-cc-number' => '6011000990139424',
        :'data-cc-expiration' => '05/2019',
        :'data-cc-cvc' => '564',
        # :'data-amount' => '300.00'
      },
      :'Error - Declined' => {
        :'data-cc-number' => '4000000000000002',
        :'data-cc-expiration' => '05/2019',
        :'data-cc-cvc' => '564',
        # :'data-amount' => '300.00'
      },
      :'Error - Fraudulent' => {
        :'data-cc-number' => '4100000000000019',
        :'data-cc-expiration' => '05/2019',
        :'data-cc-cvc' => '564',
        # :'data-amount' => '300.00'
      },
      :'Error - CVC' => {
        :'data-cc-number' => '4000000000000127',
        :'data-cc-expiration' => '05/2019',
        :'data-cc-cvc' => '564',
        # :'data-amount' => '300.00'
      },
      :'Error - Expired' => {
        :'data-cc-number' => '4000000000000069',
        :'data-cc-expiration' => '05/2019',
        :'data-cc-cvc' => '564',
        # :'data-amount' => '300.00'
      },
      :'Error - Processing' => {
        :'data-cc-number' => '4000000000000119',
        :'data-cc-expiration' => '05/2019',
        :'data-cc-cvc' => '564',
        # :'data-amount' => '300.00'
      },
    }
  end

  private

  def process_stripe
    # Process Stripe payments
    unless @payment.stripe_transaction.token.empty? || (@payment.amount <= 0)
      begin
        Stripe::Charge.create(
          :amount => (@payment.amount * 100).to_i, # amount in cents
          :currency => 'usd',
          :source => @payment.stripe_transaction.token,
          :description => @payment.memo
        )
        true
      rescue Stripe::CardError => e
        flash[:error] = e.message
        respond_to do |format|
          # format.html { render :new }
          format.json { render :json => @payment.errors, :status => :unprocessable_entity }
          format.js { render :problem }
        end
        false
      end
    end
  end

  def payment_invoices
    if params[:invoice_id].nil?
      Customer.open_invoices(params[:customer_id])
    else
      [Invoice.find(params[:invoice_id])]
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_payment
    @payment = Payment.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def payment_params
    params.require(:payment).permit(
      :payment_type,
      :payment_date,
      :amount,
      :fee,
      :memo,
      :customer_id,
      :credits_attributes => [
        :id,
        :invoice_id,
        :amount,
      ],
      :stripe_transaction_attributes => [
        :token,
        :stripe_created,
        :card_id,
        :card_type,
        :brand,
        :name,
        :exp_month,
        :exp_year,
        :last4,
        :country,
        :funding,
        :address_line1,
        :address_line2,
        :address_state,
        :address_city,
        :address_zip,
        :address_country,
        :address_line1_check,
        :address_zip_check,
        :cvc_check,
      ],
    )
  end
end
