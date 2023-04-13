class AddCollectionToLogsExport < ActiveRecord::Migration[7.0]
  def change
    add_column :logs_exports, :collection, :string
  end
end
