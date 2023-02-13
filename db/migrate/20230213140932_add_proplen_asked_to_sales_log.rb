class AddProplenAskedToSalesLog < ActiveRecord::Migration[7.0]
  def change
    add_column :sales_logs, :proplen_asked, :integer
  end
end
