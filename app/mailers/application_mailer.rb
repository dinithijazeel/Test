class ApplicationMailer < ActionMailer::Base
  layout 'mailer'
  add_template_helper ApplicationHelper
  default from: Rails.application.config.x.company.email

  def directory(role)
    case role
    when :template_path
      ["tenants/#{Rails.application.config.x.tenant}/mail",'mail']
    when :accounting
      Rails.application.config.x.email.accounting_email
    when :invoice_from
      Rails.application.config.x.email.invoice_sender
    when :payment_from
      Rails.application.config.x.email.payment_sender
    when :payment_subject
      Rails.application.config.x.email.payment_subject
    when :proposal_reply_to
      Rails.application.config.x.email.proposal_replies
    when :proposal_subject
      Rails.application.config.x.email.proposal_subject
    when :new_account_from
      Rails.application.config.x.email.new_account_sender
    when :new_account_subject
      Rails.application.config.x.email.new_account_subject
    when :welcome_from
      Rails.application.config.x.email.welcome_sender
    when :welcome_subject
      Rails.application.config.x.email.welcome_subject
    when :welcome_questionnaire
      Rails.application.config.x.email.onboarding_questionnaire
    else
      nil
    end
  end
end
