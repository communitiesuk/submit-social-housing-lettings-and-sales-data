class RemoveManualAddressEntrySelectedFromLogs < ActiveRecord::Migration[7.2]
  def up
    remove_column :sales_logs, :manual_address_entry_selected, :boolean if column_exists?(:sales_logs, :manual_address_entry_selected)
    remove_column :lettings_logs, :manual_address_entry_selected, :boolean if column_exists?(:lettings_logs, :manual_address_entry_selected)
  end

  def down
    # Do nothing
  end
end
