class AddMonthlyChargesValueCheck < ActiveRecord::Migration[7.0]
  def change
    change_table :sales_logs, bulk: true do |t|
      t.column :monthly_charges_value_check, :integer
    end
  end
end
