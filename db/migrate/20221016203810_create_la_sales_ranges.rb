class CreateLaSalesRanges < ActiveRecord::Migration[7.0]
  def change
    create_table :la_sales_ranges do |t|
      t.string :la
      t.string :la_name
      t.integer :beds
      t.integer :soft_min, null: false
      t.integer :soft_max, null: false

      t.index %i[beds la], unique: true
      t.timestamps
    end
  end
end
