class AddPropertyNumberOfBedroomsToSalesLog < ActiveRecord::Migration[7.0]
  def change
    add_column :sales_logs, :beds, :integer
  end
end
