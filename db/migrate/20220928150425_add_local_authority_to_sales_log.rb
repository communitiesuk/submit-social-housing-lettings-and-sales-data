class AddLocalAuthorityToSalesLog < ActiveRecord::Migration[7.0]
  def change
    add_column :sales_logs, :la, :string
  end
end
