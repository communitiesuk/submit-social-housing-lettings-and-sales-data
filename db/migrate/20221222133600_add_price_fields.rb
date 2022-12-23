class AddPriceFields < ActiveRecord::Migration[7.0]
  def change
    change_table :sales_logs, bulk: true do |t|
      t.column :value, :decimal, precision: 10, scale: 2
      t.column :equity, :decimal, precision: 10, scale: 2
      t.column :discount, :decimal, precision: 10, scale: 2
      t.column :grant, :decimal, precision: 10, scale: 2
    end
  end
end
