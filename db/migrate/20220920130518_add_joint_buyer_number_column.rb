class AddJointBuyerNumberColumn < ActiveRecord::Migration[7.0]
  def change
    add_column :sales_logs, :jointmore, :integer
  end
end
