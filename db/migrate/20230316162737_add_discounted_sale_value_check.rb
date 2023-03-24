class AddDiscountedSaleValueCheck < ActiveRecord::Migration[7.0]
  def change
    add_column :sales_logs, :discounted_sale_value_check, :integer
  end
end
