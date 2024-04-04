class AddAssignedToIndex < ActiveRecord::Migration[7.0]
  def change
    remove_index :sales_logs, name: "index_sales_logs_on_created_by_id", column: :created_by_id
    remove_index :lettings_logs, name: "index_lettings_logs_on_created_by_id", column: :created_by_id
    add_index :sales_logs, :assigned_to_id
    add_index :lettings_logs, :assigned_to_id
  end
end
