class PayController < PaymentsController

  skip_before_action :authenticate_user!
  after_action :allow_iframe

  def prepaid_new
    if @customer = Customer.find_by(portal_id: params[:portal_id])
      @payment = Payment.new(amount: params[:amount] || 0)
      @payment.build_stripe_transaction
      @tests = PaymentsController.tests if Rails.application.config.x.staging
      render :prepay, layout: 'portal'
    else
      render :unknown, layout: 'portal'
    end
  end

  def prepaid_create
    if @customer = Customer.find_by(portal_id: params[:portal_id])
      # Set up payment
      @payment = make_new_payment(payment_params, false) # false to skip building credits
      @payment.payable = @customer
      @payment.client_ip = request.remote_ip
      # Locate our prepaid product
      prepaid_product = Product.find_by_sku(Rails.application.config.x.products.special_products[:prepaid])
      # Build invoice
      invoice = Invoice.new(
        terms: 0,
        invoice_date: Time.now,
        invoice_status: :open,
        contact: @customer
      )
      # Build line items
      invoice.line_items.build(
        product: prepaid_product,
        description: prepaid_product.description,
        quantity: 1,
        unit_price: @payment.amount
      )
      # Save invoice
      invoice.save!
      # Build payment credits
      @payment.credits.build(
        invoice: invoice,
        amount: @payment.amount
      )
      respond_to do |format|
        if @payment.save
          # Report to portal
          @payment.record_portal_prepayment
          # Send receipt
          PaymentMailer.payment(@payment).deliver_now
          # Send invoice
          invoice.send_invoice_later
          # Refresh
          format.js { helper_reload }
        end
      end
    end
  end

  private

  def allow_iframe
    response.headers.except! 'X-Frame-Options'
  end
end
