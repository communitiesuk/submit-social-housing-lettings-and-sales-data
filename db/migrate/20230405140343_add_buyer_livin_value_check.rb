class AddBuyerLivinValueCheck < ActiveRecord::Migration[7.0]
  def change
    add_column :sales_logs, :buyer_livein_value_check, :integer
  end
end
