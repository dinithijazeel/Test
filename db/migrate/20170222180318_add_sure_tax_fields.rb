class AddSureTaxFields < ActiveRecord::Migration
  def change
    add_column :contacts, :tax_exempt_certificate, :string, after: :discount_code
    add_column :products, :sure_tax_code, :string, after: :datasheet
    add_column :boms, :invoice_type, :integer, default: 0, after: :invoice_status
    add_column :boms, :billing_start, :datetime, after: :last_editor_id
    add_column :boms, :billing_end, :datetime, after: :billing_start
  end
end
