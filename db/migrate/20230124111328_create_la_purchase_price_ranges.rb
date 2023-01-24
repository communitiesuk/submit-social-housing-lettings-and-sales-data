class CreateLaPurchasePriceRanges < ActiveRecord::Migration[7.0]
  def change
    create_table :la_purchase_price_ranges do |t|
      t.string :la
      t.integer :bedrooms
      t.decimal :soft_min, precision: 10, scale: 2
      t.decimal :soft_max, precision: 10, scale: 2
      t.integer :start_year

      t.index %i[start_year bedrooms la], unique: true, name: "index_la_purchase_price_ranges_on_start_year_bedrooms_la"
      t.timestamps
    end
  end
end
