class ChangeLocationTypeOfUnit < ActiveRecord::Migration[7.0]
  def change
    remove_column :locations, :type_of_unit
    add_column :locations, :type_of_unit, :integer
  end
end
