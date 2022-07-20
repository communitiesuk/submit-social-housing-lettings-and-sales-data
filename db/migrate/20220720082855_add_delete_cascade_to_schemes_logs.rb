class AddDeleteCascadeToSchemesLogs < ActiveRecord::Migration[7.0]
  def up
    add_foreign_key :case_logs, :schemes, foreign_key: true, on_delete: :cascade
  end

  def down
    remove_foreign_key :case_logs, :schemes
  end
end
