class AddRelationshipTypeToOrgRelationships < ActiveRecord::Migration[7.0]
  def change
    add_column(
      :organisation_relationships,
      :relationship_type,
      :integer,
      null: false, # rubocop:disable Rails/NotNullColumn
    )
  end
end
