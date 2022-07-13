class AddUniqueIndexForOldIds < ActiveRecord::Migration[7.0]
  def change
    add_index :locations, :old_id, unique: true
  end
end
