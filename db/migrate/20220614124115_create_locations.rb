class CreateLocations < ActiveRecord::Migration[7.0]
  def change
    create_table :locations do |t|
      t.string :location_code
      t.string :postcode
      t.string :type_of_unit
      t.string :type_of_building
      t.integer :wheelchair_adaptation
      t.references :scheme, null: false, foreign_key: true
      t.string :address_line1
      t.string :address_line2
      t.string :county

      t.timestamps
    end
  end
end
