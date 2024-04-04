class AddAssignedTo < ActiveRecord::Migration[7.0]
  def change
    add_column :lettings_logs, :assigned_to_id, :integer
    add_column :sales_logs, :assigned_to_id, :integer
    
    LettingsLog.update_all("assigned_to_id=created_by_id")
    SalesLog.update_all("assigned_to_id=created_by_id")
  end
end
