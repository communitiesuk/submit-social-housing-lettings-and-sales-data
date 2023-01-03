class AddMschargeKnownToSales < ActiveRecord::Migration[7.0]
  def change
    change_table :sales_logs, bulk: true do |t|
      t.column :mscharge_known, :integer
      t.column :mscharge, :decimal, precision: 10, scale: 2
    end
  end
end
