# Preview all emails at http://localhost:3000/rails/mailers/onboarding_mailer
class ProposalMailerPreview < ActionMailer::Preview

  def proposal
    proposal = Proposal.last
    ProposalMailer.proposal(proposal)
  end

  def new_customer
    proposal = Proposal.last
    ProposalMailer.new_customer(proposal)
  end

  def new_account
    proposal = Proposal.last
    ProposalMailer.new_account(proposal)
  end

end
