class AllowDecimalStairboughtAndStairowned < ActiveRecord::Migration[7.0]
  def change
    change_column :sales_logs, :stairbought, :decimal
    change_column :sales_logs, :stairowned, :decimal
  end
end
