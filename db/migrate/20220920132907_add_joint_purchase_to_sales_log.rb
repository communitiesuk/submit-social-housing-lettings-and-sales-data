class AddJointPurchaseToSalesLog < ActiveRecord::Migration[7.0]
  def change
    add_column :sales_logs, :jointpur, :integer
  end
end
