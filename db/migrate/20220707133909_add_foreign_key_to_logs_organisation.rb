class AddForeignKeyToLogsOrganisation < ActiveRecord::Migration[7.0]
  def change
    add_reference :organisations, :case_logs, foreign_key: true, on_delete: :cascade
  end
end
