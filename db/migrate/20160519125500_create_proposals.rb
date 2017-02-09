class CreateProposals < ActiveRecord::Migration
  def change
    create_table :proposals do |t|
      #
      # Status
      t.integer :proposal_status, :index => true, :default => 0
      #
      # Proposal
      t.date   :proposal_date, :index => true
      t.string :number,        :index => true
      t.string :memo,          :null => false
      t.float  :total,         :default => 0
      t.string :pdf
      #
      # Associations
      t.belongs_to :contact,           :index => true
      t.belongs_to :service_proposal,  :index => true
      t.belongs_to :products_proposal, :index => true
      #
      # History
      t.belongs_to :creator,     :index => true
      t.belongs_to :last_editor, :index => true
      t.timestamps :null => false
    end
  end
end
