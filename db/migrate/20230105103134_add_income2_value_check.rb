class AddIncome2ValueCheck < ActiveRecord::Migration[7.0]
  def change
    add_column :sales_logs, :income2_value_check, :integer
  end
end
