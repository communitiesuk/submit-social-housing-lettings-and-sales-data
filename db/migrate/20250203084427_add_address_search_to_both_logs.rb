class AddAddressSearchToBothLogs < ActiveRecord::Migration[7.2]
  def change
    add_column :sales_logs, :address_search, :string
    add_column :lettings_logs, :address_search, :string
  end
end
