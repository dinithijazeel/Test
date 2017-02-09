class AddPortalSku < ActiveRecord::Migration
  def change
    add_column :products, :portal_sku, :string, :index => true, :after => :sku
  end
end
