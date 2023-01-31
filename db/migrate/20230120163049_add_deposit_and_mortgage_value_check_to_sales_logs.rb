class AddDepositAndMortgageValueCheckToSalesLogs < ActiveRecord::Migration[7.0]
  def change
    add_column :sales_logs, :deposit_and_mortgage_value_check, :integer
  end
end
