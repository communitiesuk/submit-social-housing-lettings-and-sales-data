class AddRetirementValueCheckToSales < ActiveRecord::Migration[7.0]
  def change
    change_table :sales_logs, bulk: true do |t|
      t.column :retirement_value_check, :integer
    end
  end
end
