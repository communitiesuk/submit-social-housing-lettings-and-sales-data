class AddUprnSelectionToSalesLog < ActiveRecord::Migration[7.0]
  def change
    add_column :sales_logs, :uprn_selection, :string
  end
end
