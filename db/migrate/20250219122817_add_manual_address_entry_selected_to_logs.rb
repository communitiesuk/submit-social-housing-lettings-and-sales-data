class AddManualAddressEntrySelectedToLogs < ActiveRecord::Migration[7.2]
  def change
    remove_column :sales_logs, :manual_address_entry_selected, :boolean, default: false
    remove_column :lettings_logs, :manual_address_entry_selected, :boolean, default: false
  end
end
