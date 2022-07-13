module Imports
  class SchemeImportService < ImportService
    def create_schemes(folder)
      import_from(folder, :create_scheme)
    end

    def create_scheme(xml_document)
      old_id = string_or_nil(xml_document, "id")
      status = string_or_nil(xml_document, "status")

      if status == "Approved"
        Scheme.create!(
          owning_organisation_id: find_owning_organisation_id(xml_document),
          managing_organisation_id: find_managing_organisation_id(xml_document),
          service_name: string_or_nil(xml_document, "name"),
          arrangement_type: string_or_nil(xml_document, "arrangement_type"),
          old_id:,
          old_visible_id: safe_string_as_integer(xml_document, "visible-id"),
        )
      else
        @logger.warn("Scheme with legacy ID #{old_id} is not approved (#{status}), skipping")
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

    def find_owning_organisation_id(xml_doc)
      old_org_id = string_or_nil(xml_doc, "institution")
      organisation = Organisation.find_by(old_org_id:)
      raise "Organisation not found with legacy ID #{old_org_id}" if organisation.nil?

      organisation.id
    end

    def find_managing_organisation_id(xml_doc)
      old_visible_id = safe_string_as_integer(xml_doc, "agent")
      return unless old_visible_id

      organisation = Organisation.find_by(old_visible_id:)
      raise "Organisation not found with legacy visible ID #{old_visible_id}" if organisation.nil?

      organisation.id
    end
  end
end
