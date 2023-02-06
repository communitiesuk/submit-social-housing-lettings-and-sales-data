class AddAboutPriceSharedOwnershipValueCheckToSalesLog < ActiveRecord::Migration[7.0]
  def change
    add_column :sales_logs, :value_value_check, :integer
  end
end
