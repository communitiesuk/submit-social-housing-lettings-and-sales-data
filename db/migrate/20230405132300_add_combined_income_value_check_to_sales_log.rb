class AddCombinedIncomeValueCheckToSalesLog < ActiveRecord::Migration[7.0]
  def change
    add_column :sales_logs, :combined_income_value_check, :integer
  end
end
