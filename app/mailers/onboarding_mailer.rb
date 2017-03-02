class OnboardingMailer < ApplicationMailer

  def new_account(proposal)
    @proposal = proposal
    to = proposal.contact.admin_email
    from = directory(:new_account_from)
    subject = directory(:new_account_subject)
    mail(to: to, from: from, subject: subject, template_path: directory(:template_path))
  end

  def welcome(proposal)
    @proposal = proposal
    to = proposal.contact.admin_email
    from = directory(:welcome_from)
    subject = directory(:welcome_sender)
    attachments['FracTEL Onboarding Questionnaire.pdf'] = File.read(directory(:welcome_questionnaire))
    mail(to: to, from: from, subject: subject, template_path: directory(:template_path))
  end
end
