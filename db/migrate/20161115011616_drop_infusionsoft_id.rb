class DropInfusionsoftId < ActiveRecord::Migration
  def change
    remove_column :contacts, :is_id
  end
end
