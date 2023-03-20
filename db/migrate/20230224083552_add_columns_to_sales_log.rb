class AddColumnsToSalesLog < ActiveRecord::Migration[7.0]
  def change
    change_table :sales_logs, bulk: true do |t|
      t.column :buy2living, :integer
      t.column :prevtenbuy2, :integer
    end
  end
end
