class AddDepositFieldsToSales < ActiveRecord::Migration[7.0]
  def change
    change_table :sales_logs, bulk: true do |t|
      t.column :deposit, :decimal, precision: 10, scale: 2
      t.column :cashdis, :decimal, precision: 10, scale: 2
    end
  end
end
