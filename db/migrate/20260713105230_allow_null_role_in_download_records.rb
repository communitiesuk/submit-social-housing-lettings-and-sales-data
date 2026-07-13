class AllowNullRoleInDownloadRecords < ActiveRecord::Migration[7.2]
  def change
    change_column_null :download_records, :user_role, true
  end
end
