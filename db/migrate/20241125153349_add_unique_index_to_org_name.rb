class AddUniqueIndexToOrgName < ActiveRecord::Migration[7.0]
  def change
    add_index :organisations, :name, unique: true
  end
end
