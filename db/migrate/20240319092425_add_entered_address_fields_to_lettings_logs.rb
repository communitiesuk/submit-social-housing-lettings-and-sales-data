class AddEnteredAddressFieldsToLettingsLogs < ActiveRecord::Migration[7.0]
  def change
    change_table :lettings_logs, bulk: true do |t|
      t.column :address_line1_as_entered, :string
      t.column :address_line2_as_entered, :string
      t.column :town_or_city_as_entered, :string
      t.column :county_as_entered, :string
      t.column :postcode_full_as_entered, :string
      t.column :la_as_entered, :string
    end
  end
end
