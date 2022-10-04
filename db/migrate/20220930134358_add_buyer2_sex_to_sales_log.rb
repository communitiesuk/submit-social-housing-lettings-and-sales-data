class AddBuyer2SexToSalesLog < ActiveRecord::Migration[7.0]
  def change
    add_column :sales_logs, :sex2, :string
  end
end
