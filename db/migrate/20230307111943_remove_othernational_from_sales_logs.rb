class RemoveOthernationalFromSalesLogs < ActiveRecord::Migration[7.0]
  def change
    remove_column :sales_logs, :othernational, :string
  end
end
