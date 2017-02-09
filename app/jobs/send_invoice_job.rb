class SendInvoiceJob < ApplicationJob
  queue_as Rails.application.config.x.tenant

  def perform(invoice_id, sender_id)
  	Invoice.find(invoice_id).send_invoice(sender_id)
  end
end
