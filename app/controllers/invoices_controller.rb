#
# InvoicesController
#
class InvoicesController < ApplicationController
  respond_to :html, :js
  before_action :set_invoice, :only => [:show, :edit, :update, :destroy]

  # GET /invoices
  def index
    authorize Invoice
    if params[:q]
      @invoices = Invoice.search(params[:q])
    else
      @invoices = Invoice.index
    end
  end

  # GET /invoices/1
  # GET /invoices/1.json
  def show
    authorize @invoice
    respond_to do |format|
      format.html do
        if params[:view] == 'preview'
          @pdf_invoice = @invoice
          render @invoice.pdf_template, :layout => 'preview'
        else
          @new_comment = Comment.build_from(@invoice.contact.becomes(Contact), current_user.id, '')
        end
      end
      format.pdf do
        pdf_invoice = @invoice.becomes(@invoice.type.constantize)
        pdf_invoice.generate_pdf
        send_file(pdf_invoice.pdf.path, :filename => pdf_invoice.pdf_filename, :type => 'application/pdf', :disposition => 'inline')
      end
    end
  end

  # GET /invoices/new
  def new
    authorize Invoice, :create?
    if params[:customer_id].nil?
      contact = Contact.new
    else
      contact = Contact.find(params[:customer_id])
    end
    @invoice = Invoice.new(
      :invoice_date =>   Date.today.strftime('%F'),
      :invoice_status => :draft,
      :contact => contact,
      :terms => contact.default_terms
    )
  end

  # GET /invoices/1/edit
  def edit
    authorize @invoice, :update?
  end

  # POST /invoices
  # POST /invoices.json
  def create
    authorize Invoice
    # Is this a regular web request?
    if params[:Invoice].nil?
      @invoice = Invoice.new(invoice_params)
    else
      api_invoice = Invoice.parse_portal(params[:Invoice])
      @invoice = Invoice.new(api_invoice)
    end
    respond_to do |format|
      if @invoice.save
        # Log invoice creation
        if api_invoice
          Comment.build_from(@invoice.contact, current_user.id, "Invoice #{@invoice.number} created: #{@invoice.memo}").save
        else
          Comment.build_from(@invoice.contact, current_user.id, "Invoice created: #{@invoice.summary}").save
        end
        # Obsolete existing invoice if it's a duplicate number
        if api_invoice && existing_invoice = Invoice
            .where(:number => api_invoice[:number])
            .where.not(:invoice_status => Invoice.invoice_statuses[:obsolete])
            .where.not(:id => @invoice.id)
            .first
          existing_invoice.update_attribute(:invoice_status, Invoice.invoice_statuses[:obsolete])
          message = "Replaced invoice #{existing_invoice.number} (#{existing_invoice.id} with #{@invoice.id})\n"
          # Log invoice replacement
          Comment.build_from(@invoice.contact, current_user.id, message).save
        end
        # Actual response
        format.html { redirect_to @invoice, :notice => 'Invoice was successfully created.' }
        format.json { render :show, status: :created, location: @invoice }
        format.js { render :update }
      else
        format.html { render :new }
        format.json { render :json => @invoice.errors, :status => :unprocessable_entity }
        format.js { render :edit }
      end
    end
  end

  # PATCH/PUT /invoices/1
  # PATCH/PUT /invoices/1.json
  def update
    authorize @invoice
    respond_to do |format|
      if params[:status].nil?
        ip = invoice_params
        message = 'Invoice was successfully updated.'
      else
        case params[:status]
        when 'open'
          @invoice.send_invoice_later
          @invoice.invoice_status = :open
          message = 'Invoice confirmed.'
        when 'rate'
          @invoice.update_rating
          message = 'Invoice rated.'
        when 'resend'
          @invoice.send_invoice_later
          message = 'Invoice sent.'
        when 'closed'
          @invoice.invoice_status = :closed
          message = 'Invoice closed.'
        end
        ip = {}
      end
      if @invoice.update(ip)
        format.html { redirect_to @invoice, :notice => message }
      else
        format.html { render :edit }
        format.json { render :json => @invoice.errors, :status => :unprocessable_entity }
        format.js { render :edit }
      end
    end
  end

  # DELETE /invoices/1
  # DELETE /invoices/1.json
  def destroy
    authorize @invoice
    @invoice.update_attribute(:invoice_status, :obsolete)
    respond_to do |format|
      format.html { redirect_to invoices_url, notice: 'Invoice was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  private

  def set_invoice
    @invoice = Bom.find(params[:id]).becomes(Invoice)
  end

  def invoice_params
    params.require(:invoice).permit(Invoice.controller_params)
  end
end
