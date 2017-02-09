class ProposalMailer < ApplicationMailer
  layout 'mailer'
  add_template_helper ApplicationHelper

  def proposal(proposal)
    @proposal = proposal
    # to = User.current.email
    to = proposal.contact.admin_email
    from = proposal.owner.email
    reply_to = Rails.application.config.x.email.proposal_replies
    subject = Rails.application.config.x.email.proposal_subject
    attachments[@proposal.pdf_filename] = File.read(@proposal.pdf.path)
    mail(to: to, from: from, reply_to: reply_to, subject: subject, template_path: "tenants/#{Rails.application.config.x.tenant}/email")
  end

  # TODO: Move to OnboardingMailer
  def new_account(proposal)
    @proposal = proposal
    # to = User.current.email
    to = proposal.contact.admin_email
    from = Rails.application.config.x.email.new_account_sender
    subject = Rails.application.config.x.email.new_account_subject
    mail(to: to, from: from, subject: subject, template_path: "tenants/#{Rails.application.config.x.tenant}/email")
  end

  # TODO: Move to OnboardingMailer
  def welcome(proposal)
    @proposal = proposal
    # to = User.current.email
    to = proposal.contact.admin_email
    from = Rails.application.config.x.email.welcome_sender
    subject = Rails.application.config.x.email.welcome_subject
    attachments['FracTEL Onboarding Questionnaire.pdf'] = File.read(Rails.application.config.x.email.onboarding_questionnaire)
    mail(to: to, from: from, subject: subject, template_path: "tenants/#{Rails.application.config.x.tenant}/email")
  end
end
