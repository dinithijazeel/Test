class Admin::ServiceInvoicesController < ApplicationController
  respond_to :js

  # POST /admin/service_invoices.json
  def create
    @invoice = ServiceInvoice.parse_portal(params[:Invoice])

    # Save service invoice for replay
    directory = "#{Rails.root}/service_invoices/"
    File.open(File.join(directory, "#{@invoice.number}.json"), 'w') do |f|
      f.puts params[:Invoice].to_json
    end

    respond_to do |format|
      if @invoice.errors.empty? && @invoice.save
        # Log invoice creation
        Comment.build_from(@invoice.contact, current_user.id, "Invoice #{@invoice.number} created: #{@invoice.memo}").save
        # Obsolete existing invoice if it's a duplicate number
        if existing_invoice = Invoice
            .where(:number => @invoice.number)
            .where.not(:invoice_status => Invoice.invoice_statuses[:obsolete])
            .where.not(:id => @invoice.id)
            .first
          existing_invoice.update_attribute(:invoice_status, Invoice.invoice_statuses[:obsolete])
          # Log invoice replacement
          message = "Replaced invoice #{existing_invoice.number} (#{existing_invoice.id} with #{@invoice.id})\n"
          Comment.build_from(@invoice.contact, current_user.id, message).save
        end
        # Send invoice if it's open
        @invoice.send_invoice_later if @invoice.invoice_status == 'open'
        # Actual response
        format.json { render :show, status: :created, location: [:admin, @invoice] }
      else
        format.json { render :json => @invoice.errors, :status => :unprocessable_entity }
      end
    end
  end
end
