class AddDiscardedAt < ActiveRecord::Migration[7.0]
  def change
    add_column :collection_resources, :discarded_at, :datetime
  end
end
