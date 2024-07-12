class AddDiscardedAtToOrganisations < ActiveRecord::Migration[7.0]
  def change
    add_column :organisations, :discarded_at, :datetime
  end
end
