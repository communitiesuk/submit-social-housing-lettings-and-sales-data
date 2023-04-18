class AddPercentageDiscountValueCheck < ActiveRecord::Migration[7.0]
  def change
    add_column :sales_logs, :percentage_discount_value_check, :integer
  end
end
