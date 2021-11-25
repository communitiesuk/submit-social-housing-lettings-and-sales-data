class RemoveOldFields < ActiveRecord::Migration[6.1]
  def up
    remove_column :case_logs, :property_building_type
  end

  def down
    add_column :case_logs, :property_building_type, :string
  end
end
