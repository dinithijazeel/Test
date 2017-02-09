class AddBomAndLineItemParanoia < ActiveRecord::Migration
  def change
    add_column :boms, :deleted_at, :datetime, index: true
    add_column :line_items, :deleted_at, :datetime, index: true
  end
end
