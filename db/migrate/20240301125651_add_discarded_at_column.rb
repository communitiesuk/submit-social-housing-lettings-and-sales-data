class AddDiscardedAtColumn < ActiveRecord::Migration[7.0]
  def change
    add_column :locations, :discarded_at, :datetime
  end
end
