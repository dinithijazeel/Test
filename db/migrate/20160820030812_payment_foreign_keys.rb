class PaymentForeignKeys < ActiveRecord::Migration
  def change
    #
    # Payments
    add_foreign_key :payments, :contacts, :column => :customer_id
    add_foreign_key :payments, :users,    :column => :creator_id
    #
    # Stripe Transactions
    add_foreign_key :stripe_transactions, :payments, :column => :payment_id
    #
    # Credits
    add_foreign_key :credits, :payments, :column => :payment_id
    add_foreign_key :credits, :boms, :column => :invoice_id
    add_foreign_key :credits, :users, :column => :creator_id
  end
end
