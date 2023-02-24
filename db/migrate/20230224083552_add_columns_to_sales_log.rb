class AddColumnsToSalesLog < ActiveRecord::Migration[7.0]
  def change
    add_column :sales_logs, :buy2living, :integer
    add_column :sales_logs, :prevtenbuy2, :integer
  end
end
