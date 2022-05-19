class AddEmptyExportToLogsExports < ActiveRecord::Migration[7.0]
  def change
    add_column :logs_exports, :empty_export, :boolean, default: false, null: false
  end
end
