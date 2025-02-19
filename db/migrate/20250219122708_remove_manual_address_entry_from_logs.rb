class RemoveManualAddressEntryFromLogs < ActiveRecord::Migration[7.2]
  def change
    if column_exists?(:sales_logs, :manual_address_entry_selected)
      remove_column :sales_logs, :manual_address_entry_selected, :boolean
    end

    if column_exists?(:lettings_logs, :manual_address_entry_selected)
      remove_column :lettings_logs, :manual_address_entry_selected, :boolean
    end
  end
end
