class AddPaymentToken < ActiveRecord::Migration
  def change
    add_column :boms, :payment_token, :string, index: true, after: :did_url
  end
end
