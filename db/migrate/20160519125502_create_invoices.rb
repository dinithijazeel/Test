class CreateInvoices < ActiveRecord::Migration
  def change
    create_table :invoices do |t|
      #
      # Invoice
      t.string  :number,         :index => :unique, :null => true
      t.date    :invoice_date,   :index => true
      t.integer :invoice_status, :index => true, :default => 0
      t.integer :invoice_type,   :index => true, :default => 0
      t.integer :terms,          :index => true
      #
      # Amounts
      t.float   :invoice_total,  :default => 0
      t.float   :total_payments, :default => 0
      t.float   :total_due,      :default => 0
      t.integer :payment_status, :index => true, :default => 0
      #
      # Text
      t.text   :description, :null => false
      t.string :memo,        :null => false
      #
      # Associations
      t.belongs_to :contact, :index => true
      #
      # History
      t.belongs_to :creator,     :index => true
      t.belongs_to :last_editor, :index => true
      t.timestamps :null => false
    end
  end
end
