class InvoiceMailer < ApplicationMailer

  def invoice(invoice)
    @invoice = invoice.becomes(invoice.type.constantize)
    to = invoice.contact.invoice_email
    from = directory(:invoice_from)
    cc = directory(:accounting)
    # TODO: Use some sort of token substitution for invoice subject
    subject = "#{Rails.application.config.x.company.name} Invoice #{@invoice.contact.company_name} #{@invoice.invoice_date}"
    attachments[@invoice.pdf_filename] = File.read(@invoice.pdf.path)
    mail(to: to, from: from, cc: cc, subject: subject, template_path: directory(:template_path))
  end
end
