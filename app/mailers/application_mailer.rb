class ApplicationMailer < ActionMailer::Base
  layout 'mailer'
  add_template_helper ApplicationHelper
  default from: Conf.id.contact.no_reply_email

  def full_email(source)
    "#{Conf.id.contact[source].name} <#{Conf.id.contact[source].email}>"
  end

  def directory(role)
    case role
    when :template_path
      ["tenants/#{Conf.tenant}/mail",'mail']
    when :accounting, :billing, :sales, :onboarding, :welcome
      full_email(role)
    when :statement_subject
      Conf.email.statement_subject
    when :payment_subject
      Conf.email.payment_subject
    when :proposal_subject
      Conf.email.proposal_subject
    when :new_account_subject
      Conf.email.new_account_subject
    when :welcome_subject
      Conf.email.welcome_subject
    when :welcome_questionnaire
      "#{Rails.root}/config/profiles/#{Conf.tenant}/pdf/questionnaire.pdf"
    else
      nil
    end
  end
end
