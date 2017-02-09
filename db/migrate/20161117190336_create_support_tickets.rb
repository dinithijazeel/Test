class CreateSupportTickets < ActiveRecord::Migration
  def change
    create_table :support_tickets do |t|
      t.string :reference
      t.string :ticket_status
      #
      # Polymorphic Support
      t.integer :supportable_id, index: true
      t.string :supportable_type, index: true
      #
      # Integration
      t.integer :system, index: true, default:0
      t.integer :foreign_id, index: true
      #
      # Associations
      t.belongs_to :onboarding, index: true
      t.belongs_to :contact, index: true
      #
      # History
      t.timestamp :synced_at
      t.timestamps null: false
    end
  end
end
