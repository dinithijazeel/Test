class PaymentMailer < ApplicationMailer

  def payment(payment)
    @payment = payment
    to = payment.payable_contact.invoice_email
    from = directory(:payment_from)
    cc = directory(:accounting)
    subject = directory(:payment_subject)
    mail(to: to, from: from, cc: cc, subject: subject, template_path: directory(:template_path))
  end
end
