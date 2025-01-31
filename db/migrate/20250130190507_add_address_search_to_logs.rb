class AddAddressSearchToLogs < ActiveRecord::Migration[7.2]
  def change
    unless column_exists?(:sales_logs, :address_search)
      add_column :sales_logs, :address_search, :string
    end

    unless column_exists?(:lettings_logs, :address_search)
      add_column :lettings_logs, :address_search, :string
    end
  end
end
