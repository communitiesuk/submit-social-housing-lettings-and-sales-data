module Imports
  class OrganisationLaImportService < ImportService
    def create_organisation_las(folder)
      import_from(folder, :create_organisation_la)
    end

  private

    def create_organisation_la(xml_document)
      xml_doc = xml_document.remove_namespaces!
      organisation = Organisation.find_by(old_org_id: record_field_value(xml_document, "InstitutionId"))

      OrganisationLa.create!(
        organisation:,
        ons_code: record_field_value(xml_document, "ONSCode"),
      )
    end

    def record_field_value(xml_document, field)
      xml_document.at_xpath("//#{field}")&.text
    end
  end
end
