class AddBuildheightclassToSalesLogs < ActiveRecord::Migration[7.2]
  def change
    add_column :sales_logs, :buildheightclass, :integer
  end
end
