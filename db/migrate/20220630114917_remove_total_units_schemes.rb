class RemoveTotalUnitsSchemes < ActiveRecord::Migration[7.0]
  def change
    remove_column :schemes, :total_units, :integer
  end
end
