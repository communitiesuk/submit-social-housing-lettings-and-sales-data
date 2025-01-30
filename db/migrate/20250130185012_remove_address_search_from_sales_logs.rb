class RemoveAddressSearchFromSalesLogs < ActiveRecord::Migration[7.2]
  def change
    remove_column :sales_logs, :address_search, :string
  end
end
