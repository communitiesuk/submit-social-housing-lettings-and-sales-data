class AddEnteredAddressFieldsToLettingsLogs < ActiveRecord::Migration[7.0]
  def change
    add_column :lettings_logs, :address_line1_as_entered, :string
    add_column :lettings_logs, :address_line2_as_entered, :string
    add_column :lettings_logs, :town_or_city_as_entered, :string
    add_column :lettings_logs, :county_as_entered, :string
    add_column :lettings_logs, :postcode_full_as_entered, :string
    add_column :lettings_logs, :la_as_entered, :string
  end
end
