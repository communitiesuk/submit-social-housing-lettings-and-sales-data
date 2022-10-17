class AddPurchasePriceToSalesLog < ActiveRecord::Migration[7.0]
  def change
    add_column :sales_logs, :la, :string
    add_column :sales_logs, :purchase_price, :integer
  end
end
