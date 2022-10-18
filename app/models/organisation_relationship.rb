class OrganisationRelationship < ApplicationRecord
  belongs_to :child_organisation, class_name: "Organisation"
  belongs_to :parent_organisation, class_name: "Organisation"

  OWNING = "owning".freeze
  MANAGING = "managing".freeze
  RELATIONSHIP_TYPE = {
    OWNING => 0,
    MANAGING => 1,
  }.freeze

  enum relationship_type: RELATIONSHIP_TYPE
end
