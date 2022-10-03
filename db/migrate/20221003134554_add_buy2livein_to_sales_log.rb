class AddBuy2liveinToSalesLog < ActiveRecord::Migration[7.0]
  def change
    change_table :sales_logs, bulk: true do |t|
      t.column :buy2livein, :int
    end
  end
end
