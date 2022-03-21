class CreateLaRentRanges < ActiveRecord::Migration[7.0]
  def change
    create_table :la_rent_ranges do |t|
      t.integer :ranges_rent_id
      t.integer :needstype
      t.integer :provider_type
      t.string :ons_code
      t.string :la
      t.integer :beds
      t.decimal :soft_min, precision: 10, scale: 2
      t.decimal :soft_max, precision: 10, scale: 2
      t.decimal :hard_min, precision: 10, scale: 2
      t.decimal :hard_max, precision: 10, scale: 2
      t.integer :year
      t.integer :renttype

      t.index :year
      t.timestamps
    end
  end
end
