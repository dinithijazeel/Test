class CreateOpportunities < ActiveRecord::Migration
  def change
    create_table :opportunities do |t|
      #
      # Qualification
      t.string :need,           :null => false
      t.string :budget,         :null => false
      t.string :timing,         :null => false
      t.string :decision_maker, :null => false
      t.string :competition,    :null => false
      #
      # Associations
      t.belongs_to :contact,    :index => true
      #
      # Timestamps
      t.timestamps              :null => false
    end
  end
end
