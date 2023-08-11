module Imports
  class OrganisationRelationshipImportService < ImportService
    def create_organisation_relationships(folder)
      import_from(folder, :create_organisation_relationship)
    end

  private

    def create_organisation_relationship(xml_document)
      parent_organisation_id = find_organisation_id(xml_document, "parent-institution")
      child_organisation_id = find_organisation_id(xml_document, "child-institution")

      return if parent_organisation_id == child_organisation_id

      OrganisationRelationship.find_or_create_by!(parent_organisation_id:, child_organisation_id:)
    end

    def find_organisation_id(xml_doc, id_field)
      old_visible_id = string_or_nil(xml_doc, id_field)
      organisation = Organisation.find_by(old_visible_id:)
      raise "Organisation not found with legacy ID #{old_visible_id}" if organisation.nil?

      organisation.id
    end

    def string_or_nil(xml_doc, attribute)
      str = field_value(xml_doc, "institution-link", attribute)
      str.presence
    end
  end
end
