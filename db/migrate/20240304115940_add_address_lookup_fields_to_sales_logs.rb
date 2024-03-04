class AddAddressLookupFieldsToSalesLogs < ActiveRecord::Migration[7.0]
  def change
    add_column :sales_logs, :address_selection, :integer
    add_column :sales_logs, :address_line1_input, :string
    add_column :sales_logs, :postcode_full_input, :string
  end
end
