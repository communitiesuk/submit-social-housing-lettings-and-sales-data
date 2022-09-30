class AddBuildingTypeToSalesLog < ActiveRecord::Migration[7.0]
  def change
    add_column :sales_logs, :builtype, :integer
  end
end
