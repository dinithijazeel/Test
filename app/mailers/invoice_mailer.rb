class InvoiceMailer < ApplicationMailer
  layout 'mailer'
  add_template_helper ApplicationHelper

  def invoice(invoice)
    @invoice = invoice.becomes(invoice.type.constantize)
    # to = User.current.email
    to = invoice.contact.invoice_email
    from = Rails.application.config.x.email.invoice_sender
    # TODO: Use some sort of token substitution for invoice subject
    # subject = Rails.application.config.x.email.invoice_subject
    subject = "FracTEL Invoice #{@invoice.contact.company_name} #{@invoice.invoice_date}"
    attachments[@invoice.pdf_filename] = File.read(@invoice.pdf.path)
    mail(to: to, from: from, subject: subject, template_path: "tenants/#{Rails.application.config.x.tenant}/email")
  end
end
