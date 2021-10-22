class CreateIncomeRanges < ActiveRecord::Migration[6.1]
  def change
    create_table :income_ranges do |t|
      t.string :economic_status
      t.integer :soft_min
      t.integer :soft_max
      t.integer :hard_min
      t.integer :hard_max
      t.timestamps
    end
  end
end
