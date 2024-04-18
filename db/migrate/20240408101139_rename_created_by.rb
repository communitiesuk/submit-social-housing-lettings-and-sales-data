class RenameCreatedBy < ActiveRecord::Migration[7.0]
  def change
    rename_column :lettings_logs, :created_by_id, :assigned_to_id
    rename_column :sales_logs, :created_by_id, :assigned_to_id
  end
end
