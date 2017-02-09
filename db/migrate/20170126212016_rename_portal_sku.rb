class RenamePortalSku < ActiveRecord::Migration
  def change
    rename_column :products, :portal_sku, :vendor_sku
  end
end
