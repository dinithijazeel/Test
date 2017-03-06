class OnboardingMailer < ApplicationMailer

  def new_account(proposal)
    @proposal = proposal
    to = "#{proposal.contact.contact_first} #{proposal.contact.contact_last} <#{proposal.contact.admin_email}>"
    from = directory(:onboarding)
    subject = directory(:new_account_subject)
    mail(to: to, from: from, subject: subject, template_path: directory(:template_path))
  end

  def welcome(proposal)
    @proposal = proposal
    to = "#{proposal.contact.contact_first} #{proposal.contact.contact_last} <#{proposal.contact.admin_email}>"
    from = directory(:welcome)
    subject = directory(:welcome_subject)
    attachments["#{Conf.id.name} Onboarding Questionnaire.pdf"] = File.read(directory(:welcome_questionnaire))
    mail(to: to, from: from, subject: subject, template_path: directory(:template_path))
  end
end
