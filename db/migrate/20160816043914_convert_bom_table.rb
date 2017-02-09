class ConvertBomTable < ActiveRecord::Migration
  def change
    # Update proposals table
    rename_column :proposals, :service_proposal_id, :services_proposal_id
    # Update line items table
    rename_column :line_items, :invoice_id, :bom_id
    # Update BOM table
    rename_table :invoices, :boms
    add_column :boms, :type, :string, :after => :id, :index => true
    remove_column :boms, :invoice_type
    remove_column :boms, :description
    # Update BOM data
    execute <<-SQL
      UPDATE `boms` SET `type` = 'ServicesProposal' WHERE `id` IN (SELECT `services_proposal_id` FROM `proposals`);
    SQL
    execute <<-SQL
      UPDATE `boms` SET `type` = 'ProductsProposal' WHERE `id` IN (SELECT `products_proposal_id` FROM `proposals`);
    SQL
  end
end
