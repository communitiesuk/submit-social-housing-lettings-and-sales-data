class RemoveTypeOfBuilding < ActiveRecord::Migration[7.0]
  def change
    remove_column :locations, :type_of_building, :string
  end
end
