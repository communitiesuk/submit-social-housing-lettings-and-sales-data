class ChangeOldVisibleIdType < ActiveRecord::Migration[7.0]
  def up
    change_column :organisations, :old_visible_id, :string
    change_column :schemes, :old_visible_id, :string
    change_column :locations, :old_visible_id, :string
  end

  def down
    change_column :organisations, :old_visible_id, :integer
    change_column :schemes, :old_visible_id, :integer
    change_column :locations, :old_visible_id, :integer
  end
end
