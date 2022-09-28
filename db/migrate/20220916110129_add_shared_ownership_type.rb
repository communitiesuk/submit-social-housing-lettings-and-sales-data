class AddSharedOwnershipType < ActiveRecord::Migration[7.0]
  def change
    add_column :sales_logs, :type, :integer
  end
end
