class RenameEconomicStatusFields < ActiveRecord::Migration[6.1]
  def up
    change_table :case_logs, bulk: true do |t|
      t.rename :person_2_economic, :person_2_economic_status
      t.rename :person_3_economic, :person_3_economic_status
      t.rename :person_4_economic, :person_4_economic_status
      t.rename :person_5_economic, :person_5_economic_status
      t.rename :person_6_economic, :person_6_economic_status
      t.rename :person_7_economic, :person_7_economic_status
      t.rename :person_8_economic, :person_8_economic_status
    end
    remove_column :case_logs, :postcode
  end

  def down
    change_table :case_logs, bulk: true do |t|
      t.rename :person_2_economic_status, :person_2_economic
      t.rename :person_3_economic_status, :person_3_economic
      t.rename :person_4_economic_status, :person_4_economic
      t.rename :person_5_economic_status, :person_5_economic
      t.rename :person_6_economic_status, :person_6_economic
      t.rename :person_7_economic_status, :person_7_economic
      t.rename :person_8_economic_status, :person_8_economic
    end
    add_column :case_logs, :postcode, :string
  end
end
