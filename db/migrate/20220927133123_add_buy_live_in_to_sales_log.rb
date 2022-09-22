class AddBuyLiveInToSalesLog < ActiveRecord::Migration[7.0]
  def change
    add_column :sales_logs, :buylivein, :integer
  end
end
