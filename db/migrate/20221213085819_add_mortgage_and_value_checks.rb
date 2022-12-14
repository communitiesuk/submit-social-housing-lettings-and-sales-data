class AddMortgageAndValueChecks < ActiveRecord::Migration[7.0]
  def change
    change_table :sales_logs, bulk: true do |t|
      t.column :income1_value_check, :integer
      t.column :mortgage, :integer
      t.column :inc2mort, :integer
      t.column :mortgage_value_check, :integer
    end
  end
end
