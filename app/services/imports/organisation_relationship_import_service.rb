module Imports
  class OrganisationRelationshipImportService < ImportService
    def create_organisation_relationships(folder)
      import_from(folder, :create_organisation_relationships)
    end

    private

    def create_organisation_relationship(xml_document)
      parent_organisation_id = find_organisation_id(xml_document, "parent-institution")
      child_organisation_id = find_organisation_id(xml_document, "child-institution")

      return if parent_organisation_id == child_organisation_id

      OrganisationRelationship.find_or_create_by!(parent_organisation_id:, child_organisation_id:)
    end
  end
end
