class ChangeLocationTypeOfUnit < ActiveRecord::Migration[7.0]
  change_table :locations, bulk: true do |t|
    t.remove :type_of_unit
    t.integer :type_of_unit
  end
end
