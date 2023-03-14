class AddNationalbuy2ToSalesLogs < ActiveRecord::Migration[7.0]
  def change
    add_column :sales_logs, :nationalbuy2, :integer
  end
end
