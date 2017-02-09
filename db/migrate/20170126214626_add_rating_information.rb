class AddRatingInformation < ActiveRecord::Migration
  def change
    add_column :boms, :rating_status, :integer, index: true, default: 0, after: :invoice_status
    add_column :boms, :rated_at, :datetime, after: :last_editor_id
  end
end
