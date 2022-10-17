class OrganisationRelationship < ApplicationRecord
  belongs_to :child_organisation, class_name: "Organisation"
  belongs_to :parent_organisation, class_name: "Organisation"

  RELATIONSHIP_TYPE = {
    "owning": 0,
    "managing": 1,
  }.freeze

  enum relationship_type: RELATIONSHIP_TYPE
end
