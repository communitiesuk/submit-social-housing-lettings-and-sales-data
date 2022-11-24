class DeleteRelationshipType < ActiveRecord::Migration[7.0]
  def change
    remove_column :organisation_relationships, :relationship_type, :integer, null: false
  end
end
