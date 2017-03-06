class ProposalMailer < ApplicationMailer

  def proposal(proposal)
    @proposal = proposal
    to = "#{proposal.contact.contact_first} #{proposal.contact.contact_last} <#{proposal.contact.admin_email}>"
    from = "#{proposal.owner.first_name} #{proposal.owner.last_name} <#{proposal.owner.email}>"
    reply_to = directory(:sales)
    subject = directory(:proposal_subject)
    attachments[@proposal.pdf_filename] = File.read(@proposal.pdf.path)
    mail(to: to, from: from, reply_to: reply_to, subject: subject, template_path: directory(:template_path))
  end
end
