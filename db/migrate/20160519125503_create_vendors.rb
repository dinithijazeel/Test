class CreateVendors < ActiveRecord::Migration
  def change
    create_table :vendors do |t|
      #
      # Vendors
    	t.string  :name,   :index => true, :null => false
      t.boolean :active, :default => 1
      #
      # History
      t.timestamps :null => false
    end
  end
end
