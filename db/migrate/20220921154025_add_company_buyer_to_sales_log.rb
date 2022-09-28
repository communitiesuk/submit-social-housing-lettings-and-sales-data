class AddCompanyBuyerToSalesLog < ActiveRecord::Migration[7.0]
  def change
    add_column :sales_logs, :companybuy, :integer
  end
end
