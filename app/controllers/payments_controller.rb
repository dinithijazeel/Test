class PaymentsController < ApplicationController
  respond_to :html, :js
  before_action :set_payment, :only => [:show, :edit, :update, :destroy]

  # GET /payments/:id
  def show
    render :show, layout: false
  end

  def new
    if payable
      @payment = make_new_payment
      # Add date and amount to payment
      @payment.payment_date = Date.today
      # Figure out customer for payment
      @payment.customer_id = params[:customer_id] || @payment.payable_contact.id
      # Create stripe transaction
      @payment.build_stripe_transaction
      # Load tests if we're in development
      @tests = PaymentsController.tests if Conf.staging.engaged
      # Figure out which form to show
      if params[:payment_token] || params[:account_token]
        render :pay, layout: 'portal'
      else
        render :edit, layout: false
      end
    else
      render :unknown, layout: 'portal'
    end
  end

  def create
    # Build invoice and payment
    @payment = make_new_payment(payment_params, false) # false to skip building credits
    @payment.client_ip = request.remote_ip
    # Respond
    if @payment.save
      # Report to portal
      @payment.record_portal_payment unless @payment.payable.is_a?(Customer)
      # Log activity
      Comment.build_from(@payment.customer, Conf.id.default_user_id, "Payment received: $ #{format("%#.2f", @payment.amount)} (#{@payment.payment_account})").save
      # Send payment receipt
      PaymentMailer.payment(@payment).deliver_now
      # Reload page to show successful payment
      respond_to do |format|
        format.js { helper_reload }
      end
    else
      respond_to do |format|
        # Show problems
        format.js { render :problem }
      end
    end
  end

  def edit
    # Add any open invoices
    payment_invoices.each do |invoice|
      unless @payment.credits.exists?(:invoice_id => invoice.id)
        @payment.credits.build(:invoice => invoice)
      end
    end
  end

  def update
    # Update payment attributes
    @payment.attributes = payment_params
    # Respond
    if @payment.valid?
      # Attempt to run Stripe payments
      if @payment.payment_account == 'Stripe'
        success = process_stripe
      else
        success = true
      end
      # Continue processing if Stripe was good
      if success
        @payment.client_ip = request.remote_ip
        @payment.save
        Comment.build_from(@payment.customer, current_user.id, "Payment updated: $ #{format("%#.2f", @payment.amount)} (#{@payment.payment_account})").save
        respond_to do |format|
          format.js { helper_reload }
        end
      end
    else
      respond_to do |format|
        @tests = PaymentsController.tests if Conf.staging.engaged
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

  def payable
    if params[:customer_id]
      Customer.find(params[:customer_id]).becomes(Customer)
    elsif params[:invoice_id]
      Bom.find(params[:invoice_id]).becomes(Invoice)
    # TODO: Get rid of this once PayController goes away?
    elsif params[:payment_token]
      Bom.find_by_payment_token(params[:payment_token]).becomes(Invoice)
    elsif params[:account_token]
       invoice = Bom.find_by_payment_token(params[:account_token])
       invoice ? invoice.contact : nil
    elsif params[:proposal_id]
      Proposal.find(params[:proposal_id])
    else
      nil
    end
  end

  def make_new_payment(params = {}, build_credits = true)
    # Create new payment
    payment = Payment.new(params)
    # Attach payable
    payment.payable = payable
    if payment.payable
      # Set type
      payment.payable_type = payable.type unless payable.is_a?(Proposal) # Rails shortcoming
      # Set amount
      amount_left = payment.amount = payable.payable_amount unless params[:amount]
      # Create payment credits from invoices
      if build_credits
        invoices = payable.payment_invoices
        invoices.each do |invoice|
          if amount_left > 0
            amount_to_apply = amount_left > invoice.total_due ? invoice.total_due : amount_left
            payment.credits.build(:invoice => invoice, :amount => amount_to_apply)
            amount_left -= amount_to_apply
          else
            payment.credits.build(:invoice => invoice)
          end
        end
      end
    end
    payment
  end

  def set_payment
    @payment = Payment.find(params[:id])
  end

  def payment_params
    params.require(:payment).permit(Payment.controller_params)
  end
end
