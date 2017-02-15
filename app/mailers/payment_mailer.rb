class PaymentMailer < ApplicationMailer
  layout 'mailer'
  add_template_helper ApplicationHelper

  def payment(payment)
    # @payment = payment
    # # to = User.current.email
    # # to = payment.payable.contact.admin_email
    # to = 'ian@fractel.net'
    # from = Rails.application.config.x.email.payment_sender
    # subject = Rails.application.config.x.email.payment_subject
    # mail(to: to, from: from, subject: subject, template_path: "tenants/#{Rails.application.config.x.tenant}/email")
  end
end
