class AddAddressSearchValueCheckToSalesLogs < ActiveRecord::Migration[7.0]
  def change
    add_column :sales_logs, :address_search_value_check, :integer
  end
end
