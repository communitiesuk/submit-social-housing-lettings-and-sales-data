class AddSaledateCheckToSalesLog < ActiveRecord::Migration[7.0]
  def change
    add_column :sales_logs, :saledate_check, :integer
  end
end
