class StatementMailer < ApplicationMailer

  def statement(customer)
    @customer = customer
    to = customer.invoice_email
    from = directory(:statement_from)
    cc = directory(:accounting)
    subject = directory(:statement_subject)
    attachments[@customer.statement_filename] = File.read(@customer.generate_statement)
    mail(to: to, from: from, cc: cc, subject: subject, template_path: directory(:template_path))
  end
end
