class AddOwnershipSchemeToSalesLog < ActiveRecord::Migration[7.0]
  def change
    add_column :sales_logs, :ownershipsch, :integer
  end
end
