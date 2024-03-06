class AddNoAddressFoundCheckToLettingsLogs < ActiveRecord::Migration[7.0]
  def change
    add_column :lettings_logs, :address_search_value_check, :integer
  end
end
