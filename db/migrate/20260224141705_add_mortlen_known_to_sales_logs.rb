class AddMortlenKnownToSalesLogs < ActiveRecord::Migration[7.2]
  def change
    add_column :sales_logs, :mortlen_known, :integer
  end
end
