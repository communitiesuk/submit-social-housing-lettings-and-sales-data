class AddEcstat2ToSalesLog < ActiveRecord::Migration[7.0]
  def change
    change_table :sales_logs, bulk: true do |t|
      t.column :ecstat2, :int
    end
  end
end
