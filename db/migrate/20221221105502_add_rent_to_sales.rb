class AddRentToSales < ActiveRecord::Migration[7.0]
  def change
    change_table :sales_logs, bulk: true do |t|
      t.column :mrent, :decimal, precision: 10, scale: 2
    end
  end
end
