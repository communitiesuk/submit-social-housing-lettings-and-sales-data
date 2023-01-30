class AddGrantValueCheckToSalesLog < ActiveRecord::Migration[7.0]
  def change
    add_column :sales_logs, :grant_value_check, :integer
  end
end
