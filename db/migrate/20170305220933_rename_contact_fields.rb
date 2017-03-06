class RenameContactFields < ActiveRecord::Migration
  def change
    rename_column :contacts, :portal_id, :account_code
    rename_column :contacts, :affiliate_id, :affiliate_code
  end
end
