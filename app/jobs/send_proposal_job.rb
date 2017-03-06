class SendProposalJob < ApplicationJob

  def perform(proposal_id, sender_id)
  	Proposal.find(proposal_id).send_proposal(sender_id)
  end
end
