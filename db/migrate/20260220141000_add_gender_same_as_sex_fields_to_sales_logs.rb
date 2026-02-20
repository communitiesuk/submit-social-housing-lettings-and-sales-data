class AddGenderSameAsSexFieldsToSalesLogs < ActiveRecord::Migration[7.0]
  def change
    change_table :sales_logs, bulk: true do |t|
      t.integer :gender_same_as_sex1
      t.integer :gender_same_as_sex2
      t.integer :gender_same_as_sex3
      t.integer :gender_same_as_sex4
      t.integer :gender_same_as_sex5
      t.integer :gender_same_as_sex6
      t.string :gender_description1
      t.string :gender_description2
      t.string :gender_description3
      t.string :gender_description4
      t.string :gender_description5
      t.string :gender_description6
    end
  end
end
