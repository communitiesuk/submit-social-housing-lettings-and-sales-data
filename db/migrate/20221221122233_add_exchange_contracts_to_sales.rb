class AddExchangeContractsToSales < ActiveRecord::Migration[7.0]
  def change
    change_table :sales_logs, bulk: true do |t|
      t.column :exdate, :datetime
      t.column :exday, :integer
      t.column :exmonth, :integer
      t.column :exyear, :integer
      t.column :resale, :integer
    end
  end
end
