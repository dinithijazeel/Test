class AddPdfToBoms < ActiveRecord::Migration
  def change
    add_column :boms, :pdf, :string, :after => :memo
  end
end
