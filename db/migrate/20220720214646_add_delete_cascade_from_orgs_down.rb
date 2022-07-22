class AddDeleteCascadeFromOrgsDown < ActiveRecord::Migration[7.0]
  def change
    remove_foreign_key :schemes, :organisations, column: "owning_organisation_id"
    remove_foreign_key :schemes, :organisations, column: "managing_organisation_id"
    add_foreign_key :schemes, :organisations, column: "owning_organisation_id", on_delete: :cascade
  end
end
