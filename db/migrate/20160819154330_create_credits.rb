class CreateCredits < ActiveRecord::Migration
  def change
    create_table :credits do |t|
      #
      # Credit
      t.float :amount
      #
      # Associations
      t.belongs_to :payment, :index => true
      t.belongs_to :invoice, :index => true
      #
      # History
      t.belongs_to :creator, :index => true
      t.timestamps :null => false
    end
  end
end
