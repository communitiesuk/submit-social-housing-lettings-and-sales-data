class AddPurchid < ActiveRecord::Migration[7.0]
  def change
    add_column :sales_logs, :purchid, :string
  end
end
