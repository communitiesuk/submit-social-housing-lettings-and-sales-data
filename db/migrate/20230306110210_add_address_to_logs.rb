class AddAddressToLogs < ActiveRecord::Migration[7.0]
  change_table :sales_logs, bulk: true do |t|
    t.column :address_line1, :string
    t.column :address_line2, :string
    t.column :town_or_city, :string
    t.column :county, :string
  end

  change_table :lettings_logs, bulk: true do |t|
    t.column :address_line1, :string
    t.column :address_line2, :string
    t.column :town_or_city, :string
    t.column :county, :string
  end
end
