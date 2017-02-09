class AddForeignKeys < ActiveRecord::Migration
  def change
    #
    # Contacts
    #
    add_foreign_key :contacts, :users, :column => :creator_id
    add_foreign_key :contacts, :users, :column => :last_editor_id
    #
    # Invoices
    add_foreign_key :invoices, :contacts, :column => :contact_id
    add_foreign_key :invoices, :users,    :column => :creator_id
    add_foreign_key :invoices, :users,    :column => :last_editor_id
    #
    # Line Items
    add_foreign_key :line_items, :invoices, :column => :invoice_id
    add_foreign_key :line_items, :products, :column => :product_id
    #
    # Onboarding
    add_foreign_key :onboarding, :proposals, :column => :proposal_id
    #
    # Opportunities
    add_foreign_key :opportunities, :contacts, :column => :contact_id
    #
    # Payments
    add_foreign_key :payments, :invoices, :column => :invoice_id
    add_foreign_key :payments, :users,    :column => :creator_id
    #
    # Products
    add_foreign_key :products, :vendors, :column => :vendor_id
    #
    # Proposals
    add_foreign_key :proposals, :contacts, :column => :contact_id
    add_foreign_key :proposals, :invoices, :column => :service_proposal_id
    add_foreign_key :proposals, :invoices, :column => :products_proposal_id
    add_foreign_key :proposals, :users,    :column => :creator_id
    add_foreign_key :proposals, :users,    :column => :last_editor_id
  end
end
