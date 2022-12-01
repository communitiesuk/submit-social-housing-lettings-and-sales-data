class AddMortgage1ToSales < ActiveRecord::Migration[7.0]
  def change
    change_table :sales_logs, bulk: true do |t|
      t.column :inc1mort, :int
    end
  end
end
