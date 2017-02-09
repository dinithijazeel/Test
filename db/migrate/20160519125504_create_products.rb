class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      #
      # Product
      t.string  :sku,            :index => true, :null => false
      t.string  :name,           :index => true, :null => false
      t.text    :description,    :null => false
      t.float   :price,          :null => true
      t.float   :weight,         :null => true
      t.string  :units,          :null => false
      t.float   :default_quantity, :default => 1.0
      #
      # Properties
      t.integer :product_status, :default => 0, :index => true
      t.integer :product_type, :default => 0, :index => true
      t.integer :billing,      :default => 0, :index => true
      t.boolean :taxable,      :default => true
      t.boolean :fixed_price,  :default => true
      t.string  :datasheet
      #
      # Associations
      t.belongs_to :vendor, :index => true
      #
      # History
      t.timestamps :null => false
    end
  end
end
