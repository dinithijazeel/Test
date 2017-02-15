class AddPaymentPolymorphism < ActiveRecord::Migration
  def change
    add_column :payments, :payable_id, :integer, index: true, after: :customer_id
    add_column :payments, :payable_type, :string, index: true, after: :payable_id
  end
end
