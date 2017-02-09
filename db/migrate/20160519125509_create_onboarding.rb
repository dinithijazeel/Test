class CreateOnboarding < ActiveRecord::Migration
  def change
    create_table :onboarding do |t|
      #
      # Service
      t.string :service_type, :null => true
      t.integer :service_quantity
      t.float :service_unit_price
      #
      # DIDs
      t.integer :addl_dids_quantity
      t.float :addl_dids_unit_price
      #
      # Fax
      t.integer :fax_quantity
      t.float :fax_unit_price
      #
      # Installation
      t.string :installation
      t.text :installation_notes
      #
      # Porting
      t.boolean :local_port,    :index => true
      t.boolean :tollfree_port, :index => true
      #
      # Discount
      t.float :discount
      #
      # Associations
      t.belongs_to :proposal, :index => true
      #
      # History
      t.timestamps :null => false
    end
  end
end
