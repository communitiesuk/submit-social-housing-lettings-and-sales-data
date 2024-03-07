class AddAddressLookupFieldsToSalesLogs < ActiveRecord::Migration[7.0]
  def change
    change_table :sales_logs, bulk: true do |t|
      t.integer :address_selection
      t.string :address_line1_input
      t.string :postcode_full_input
    end
  end
end
