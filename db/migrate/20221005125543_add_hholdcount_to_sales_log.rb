class AddHholdcountToSalesLog < ActiveRecord::Migration[7.0]
  def change
    change_table :sales_logs, bulk: true do |t|
      t.column :hholdcount, :int
    end
  end
end
