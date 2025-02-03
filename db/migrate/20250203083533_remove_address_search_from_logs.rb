class RemoveAddressSearchFromLogs < ActiveRecord::Migration[7.2]
  def change
    if column_exists?(:sales_logs, :address_search)
      remove_column :sales_logs, :address_search
    end

    if column_exists?(:lettings_logs, :address_search)
      remove_column :lettings_logs, :address_search
    end
  end
end
