class RenameExportTable < ActiveRecord::Migration[7.0]
  def change
    rename_table :logs_exports, :exports
  end
end
