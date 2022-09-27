class AddBuy1livein < ActiveRecord::Migration[7.0]
  def change
    add_column :sales_logs, :buy1livein, :integer
  end
end
