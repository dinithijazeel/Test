class CreateLineItems < ActiveRecord::Migration
  def change
    create_table :line_items do |t|
      #
      # Line Items
      t.string :description, :null => true
      t.float  :quantity,    :default => 0
      t.float  :unit_price,  :default => 0
      t.float  :total,       :default => 0
      #
      # Associations
      t.belongs_to :invoice, :index => true
      t.belongs_to :product, :index => true
      #
      # History
      t.timestamps :null => false
    end
  end
end
