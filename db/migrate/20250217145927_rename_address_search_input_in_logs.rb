class RenameAddressSearchInputInLogs < ActiveRecord::Migration[7.2]
  def up
    rename_column :sales_logs, :address_search_input, :manual_address_entry_selected
    rename_column :lettings_logs, :address_search_input, :manual_address_entry_selected

    change_column :sales_logs, :manual_address_entry_selected, :boolean, default: false
    change_column :lettings_logs, :manual_address_entry_selected, :boolean, default: false
  end

  def down
    rename_column :sales_logs, :manual_address_entry_selected, :address_search_input
    rename_column :lettings_logs, :manual_address_entry_selected, :address_search_input

    change_column :sales_logs, :manual_address_entry_selected, :boolean
    change_column :lettings_logs, :manual_address_entry_selected, :boolean
  end
end
