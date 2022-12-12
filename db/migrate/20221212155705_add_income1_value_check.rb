class AddIncome1ValueCheck < ActiveRecord::Migration[7.0]
  def change
    add_column :sales_logs, :income1_value_check, :integer
  end
end
