class AddMissingFieldsToLocation < ActiveRecord::Migration[7.0]
  def change
    change_table :locations, bulk: true do |t|
      t.column :old_id, :string
      t.column :old_visible_id, :integer
    end
  end
end
