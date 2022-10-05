class AddEcstat1ToSalesLog < ActiveRecord::Migration[7.0]
  def change
    change_table :sales_logs, bulk: true do |t|
      t.column :ecstat1, :int
    end
  end
end
