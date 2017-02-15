class AddClientIpToStripeTransaction < ActiveRecord::Migration
  def change
    add_column :stripe_transactions, :client_ip, :string, after: :stripe_created
  end
end
