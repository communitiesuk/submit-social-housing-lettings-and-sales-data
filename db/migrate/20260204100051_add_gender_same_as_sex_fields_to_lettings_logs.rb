class AddGenderSameAsSexFieldsToLettingsLogs < ActiveRecord::Migration[7.2]
  def change
    change_table :lettings_logs, bulk: true do |t|
      t.column :gender_same_as_sex1, :integer
      t.column :gender_same_as_sex2, :integer
      t.column :gender_same_as_sex3, :integer
      t.column :gender_same_as_sex4, :integer
      t.column :gender_same_as_sex5, :integer
      t.column :gender_same_as_sex6, :integer
      t.column :gender_same_as_sex7, :integer
      t.column :gender_same_as_sex8, :integer

      t.column :gender_description1, :string
      t.column :gender_description2, :string
      t.column :gender_description3, :string
      t.column :gender_description4, :string
      t.column :gender_description5, :string
      t.column :gender_description6, :string
      t.column :gender_description7, :string
      t.column :gender_description8, :string
    end
  end
end
