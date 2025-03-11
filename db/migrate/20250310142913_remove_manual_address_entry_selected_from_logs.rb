class RemoveManualAddressEntrySelectedFromLogs < ActiveRecord::Migration[7.2]
  class RemoveManualAddressEntrySelectedFromLogs < ActiveRecord::Migration[7.2]
    def change
      remove_column :sales_logs, :manual_address_entry_selected, :boolean if column_exists?(:sales_logs, :manual_address_entry_selected)
      remove_column :lettings_logs, :manual_address_entry_selected, :boolean if column_exists?(:lettings_logs, :manual_address_entry_selected)
    end
  end
end
