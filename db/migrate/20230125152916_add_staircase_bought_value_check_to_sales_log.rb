class AddStaircaseBoughtValueCheckToSalesLog < ActiveRecord::Migration[7.0]
  def change
    add_column :sales_logs, :staircase_bought_value_check, :integer
  end
end
