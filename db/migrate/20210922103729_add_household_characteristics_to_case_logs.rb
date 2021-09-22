class AddHouseholdCharacteristicsToCaseLogs < ActiveRecord::Migration[6.1]
  def change
    change_table :case_logs, bulk: true do |t|
      t.column :economic_status, :string
      t.column :number_of_other_members, :integer
      t.column :person_2_relationship, :string
      t.column :person_2_age, :integer
      t.column :person_2_gender, :string
      t.column :person_2_economic, :string
      t.column :person_3_relationship, :string
      t.column :person_3_age, :integer
      t.column :person_3_gender, :string
      t.column :person_3_economic, :string
      t.column :person_4_relationship, :string
      t.column :person_4_age, :integer
      t.column :person_4_gender, :string
      t.column :person_4_economic, :string
      t.column :person_5_relationship, :string
      t.column :person_5_age, :integer
      t.column :person_5_gender, :string
      t.column :person_5_economic, :string
      t.column :person_6_relationship, :string
      t.column :person_6_age, :integer
      t.column :person_6_gender, :string
      t.column :person_6_economic, :string
      t.column :person_7_relationship, :string
      t.column :person_7_age, :integer
      t.column :person_7_gender, :string
      t.column :person_7_economic, :string
      t.column :person_8_relationship, :string
      t.column :person_8_age, :integer
      t.column :person_8_gender, :string
      t.column :person_8_economic, :string
    end
  end
end
