class AddMobilityTypeToLocations < ActiveRecord::Migration[7.0]
  def change
    change_table :locations, bulk: true do |t|
      t.column :mobility_type, :string
    end
  end
end
