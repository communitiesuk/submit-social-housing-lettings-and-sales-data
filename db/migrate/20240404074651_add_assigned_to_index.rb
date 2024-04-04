class AddAssignedToIndex < ActiveRecord::Migration[7.0]
  def change
    add_index :sales_logs, :assigned_to_id
    add_index :lettings_logs, :assigned_to_id
  end
end
