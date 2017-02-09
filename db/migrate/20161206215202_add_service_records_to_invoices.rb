class AddServiceRecordsToInvoices < ActiveRecord::Migration
  def change
    add_column :boms, :cdr_url, :string, after: :portal_id
    add_column :boms, :did_url, :string, after: :cdr_url
  end
end
