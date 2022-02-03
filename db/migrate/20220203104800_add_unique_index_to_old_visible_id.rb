class AddUniqueIndexToOldVisibleId < ActiveRecord::Migration[7.0]
  add_index :organisations, :old_visible_id, unique: true
end
