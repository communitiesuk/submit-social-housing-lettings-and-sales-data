class AddHouseholdChargeField < ActiveRecord::Migration[7.0]
  def change
    change_table :case_logs, bulk: true do |t|
      t.column :household_charge, :integer
    end
  end
end
