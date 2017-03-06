class SendStatementJob < ApplicationJob

  def perform(customer_id, sender_id)
  	Customer.find(customer_id).send_statement(sender_id)
  end
end
