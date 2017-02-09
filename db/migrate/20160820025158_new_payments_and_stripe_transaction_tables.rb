class NewPaymentsAndStripeTransactionTables < ActiveRecord::Migration
  def change
    #
    # Remove old payments table
    drop_table :payments
    #
    # Create new payments table
    create_table :payments do |t|
      #
      # Transaction
      t.integer :payment_status, :default => 0, :index => true
      t.string  :payment_type, :index => true
      t.date    :payment_date, :index => true
      t.float   :amount, :null => false
      t.float   :balance, :null => false
      t.float   :fee, :default => 0
      t.text    :memo, :null => false
      #
      # Associations
      t.belongs_to :customer, :index => true
      #
      # History
      t.string     :client_ip, :null => false
      t.belongs_to :creator, :index => true
      t.timestamps :null => false
    end
  end
end
