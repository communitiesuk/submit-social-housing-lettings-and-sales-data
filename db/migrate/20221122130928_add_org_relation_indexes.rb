class AddOrgRelationIndexes < ActiveRecord::Migration[7.0]
  def change
    add_index :organisation_relationships, :child_organisation_id
    add_index :organisation_relationships, :parent_organisation_id
    add_index :organisation_relationships, %i[parent_organisation_id child_organisation_id], unique: true, name: "index_org_rel_parent_child_uniq"

    add_foreign_key :organisation_relationships, :organisations, column: :parent_organisation_id
    add_foreign_key :organisation_relationships, :organisations, column: :child_organisation_id
  end
end
