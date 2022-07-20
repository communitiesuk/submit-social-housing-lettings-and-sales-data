class AddFKeyAndDeleteCascadeToOrgLog < ActiveRecord::Migration[7.0]
  def up
    add_foreign_key :case_logs, :organisations, column: "owning_organisation_id", on_delete: :cascade
  end

  def down
    remove_foreign_key :case_logs, :organisations, column: "owning_organisation_id"
  end
end
