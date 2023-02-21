class AddStaircasesaleToSalesLogs < ActiveRecord::Migration[7.0]
  def change
    add_column :sales_logs, :staircasesale, :integer
  end
end
