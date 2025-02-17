class RemoveAddressSearchFromLogs < ActiveRecord::Migration[7.2]
  def change
    remove_column :sales_logs, :address_search, :string
    remove_column :lettings_logs, :address_search, :string
  end
end
