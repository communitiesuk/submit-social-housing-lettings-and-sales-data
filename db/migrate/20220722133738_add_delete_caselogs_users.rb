class AddDeleteCaselogsUsers < ActiveRecord::Migration[7.0]
  def change
    add_foreign_key :case_logs, :organisations, column: "owning_organisation_id", on_delete: :cascade
    add_foreign_key :users, :organisations, on_delete: :cascade
  end
end
