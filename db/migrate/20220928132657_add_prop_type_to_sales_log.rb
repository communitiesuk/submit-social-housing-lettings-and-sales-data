class AddPropTypeToSalesLog < ActiveRecord::Migration[7.0]
  def change
    add_column :sales_logs, :proptype, :integer
  end
end
