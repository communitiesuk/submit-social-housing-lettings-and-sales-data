class AddAddressSelectionToLettingsLogs < ActiveRecord::Migration[7.0]
  def change
    add_column :lettings_logs, :address_selection, :integer
  end
end
