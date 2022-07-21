class AddDeleteCascadeFromOrgsDown < ActiveRecord::Migration[7.0]
  def up
    add_foreign_key :schemes, :organisations, column: "owning_organisation_id", on_delete: :cascade
  end

  def down
    remove_foreign_key :schemes, :organisations, column: "owning_organisation_id", on_delete: :cascade
  end
end
