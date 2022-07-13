class RenameUnitsFromLocations < ActiveRecord::Migration[7.0]
  def change
    rename_column :locations, :total_units, :units
    add_column :schemes, :total_units, :integer
  end
end
