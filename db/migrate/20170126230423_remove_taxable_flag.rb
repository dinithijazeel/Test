class RemoveTaxableFlag < ActiveRecord::Migration
  def change
    remove_column :products, :taxable
  end
end
