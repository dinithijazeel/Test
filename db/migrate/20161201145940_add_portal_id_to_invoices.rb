class AddPortalIdToInvoices < ActiveRecord::Migration
  def change
    add_column :boms, :portal_id, :string, index: true, after: :contact_id
  end
end
