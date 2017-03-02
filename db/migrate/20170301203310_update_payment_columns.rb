class UpdatePaymentColumns < ActiveRecord::Migration
  def change
    rename_column :payments, :payment_type, :payment_account
    add_column :payments, :payment_type, :string, index: true, after: :payment_account
  end
end
