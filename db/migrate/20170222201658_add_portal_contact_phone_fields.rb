class AddPortalContactPhoneFields < ActiveRecord::Migration
  def change
    add_column :contacts, :cell_phone, :string, after: :phone
    add_column :contacts, :fax_phone, :string, after: :cell_phone
    add_column :contacts, :other_phone, :string, after: :fax_phone
    add_column :contacts, :other_phone_label, :string, after: :other_phone
  end
end
