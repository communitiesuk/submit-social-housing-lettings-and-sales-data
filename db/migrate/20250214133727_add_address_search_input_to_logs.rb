class AddAddressSearchInputToLogs < ActiveRecord::Migration[7.2]
  def change
    add_column :sales_logs, :address_search_input, :boolean
    add_column :lettings_logs, :address_search_input, :boolean
  end
end
