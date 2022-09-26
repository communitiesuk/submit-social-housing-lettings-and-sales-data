class AddAge1ToSalesLogs < ActiveRecord::Migration[7.0]
  def change
    add_column :sales_logs, :age1, :integer
    add_column :sales_logs, :age1_known, :integer
  end
end
