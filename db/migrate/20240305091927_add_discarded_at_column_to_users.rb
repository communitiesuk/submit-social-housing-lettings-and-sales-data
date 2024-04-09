class AddDiscardedAtColumnToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :discarded_at, :datetime
  end
end
