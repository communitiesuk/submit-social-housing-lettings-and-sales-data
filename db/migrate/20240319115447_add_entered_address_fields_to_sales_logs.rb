class AddEnteredAddressFieldsToSalesLogs < ActiveRecord::Migration[7.0]
  def change
    add_column :sales_logs, :address_line1_as_entered, :string
    add_column :sales_logs, :address_line2_as_entered, :string
    add_column :sales_logs, :town_or_city_as_entered, :string
    add_column :sales_logs, :county_as_entered, :string
    add_column :sales_logs, :postcode_full_as_entered, :string
    add_column :sales_logs, :la_as_entered, :string
  end
end
