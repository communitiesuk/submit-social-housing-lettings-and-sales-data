module Imports
  class SchemeImportService < ImportService
    def create_schemes(folder)
      import_from(folder, :create_scheme)
    end

    def create_scheme(xml_document)
      attributes = scheme_attributes(xml_document)
      if attributes["status"] == "Approved"
        Scheme.create!(
          owning_organisation_id: attributes["owning_organisation_id"],
          managing_organisation_id: attributes["managing_organisation_id"],
          service_name: attributes["service_name"],
          arrangement_type: attributes["arrangement_type"],
          old_id: attributes["old_id"],
          old_visible_id: attributes["old_visible_id"],
        )
      else
        @logger.warn("Scheme with legacy ID #{attributes['old_id']} is not approved (#{attributes['status']}), skipping")
      end
    end

  private

    def scheme_field_value(xml_document, field)
      field_value(xml_document, "mgmtgroup", field)
    end

    def string_or_nil(xml_doc, attribute)
      str = scheme_field_value(xml_doc, attribute)
      str.presence
    end

    # Safe: A string that represents only an integer (or empty/nil)
    def safe_string_as_integer(xml_doc, attribute)
      str = scheme_field_value(xml_doc, attribute)
      Integer(str, exception: false)
    end

    def scheme_attributes(xml_doc)
      attributes = {}
      attributes["old_id"] = string_or_nil(xml_doc, "id")
      attributes["old_visible_id"] = string_or_nil(xml_doc, "visible-id")
      attributes["status"] = string_or_nil(xml_doc, "status")
      attributes["service_name"] = string_or_nil(xml_doc, "name")
      attributes["arrangement_type"] = string_or_nil(xml_doc, "arrangement_type")
      attributes["owning_org_old_id"] = string_or_nil(xml_doc, "institution")
      attributes["owning_organisation_id"] = find_owning_organisation_id(attributes["owning_org_old_id"])
      attributes["management_org_old_visible_id"] = safe_string_as_integer(xml_doc, "agent")
      attributes["managing_organisation_id"] = find_managing_organisation_id(attributes["management_org_old_visible_id"])

      if attributes["arrangement_type"] == "D" && attributes["managing_organisation_id"].nil?
        attributes["managing_organisation_id"] = attributes["owning_organisation_id"]
      end

      attributes
    end

    def find_owning_organisation_id(old_org_id)
      organisation = Organisation.find_by(old_org_id:)
      raise "Organisation not found with legacy ID #{old_org_id}" if organisation.nil?

      organisation.id
    end

    def find_managing_organisation_id(old_visible_id)
      return unless old_visible_id

      organisation = Organisation.find_by(old_visible_id:)
      raise "Organisation not found with legacy visible ID #{old_visible_id}" if organisation.nil?

      organisation.id
    end
  end
end
