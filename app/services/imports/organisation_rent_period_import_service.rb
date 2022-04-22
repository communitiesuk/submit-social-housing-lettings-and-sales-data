module Imports
  class OrganisationRentPeriodImportService < ImportService
    def create_organisation_rent_periods(folder)
      import_from(folder, :create_organisation_rent_period)
    end

  private

    def create_organisation_rent_period(xml_document)
      organisation = Organisation.find_by(old_org_id: record_field_value(xml_document, "institution"))

      OrganisationRentPeriod.create!(
        organisation:,
        rent_period: Integer(record_field_value(xml_document, "period")),
      )
    end

    def record_field_value(xml_document, field)
      field_value(xml_document, "rent-period", field)
    end
  end
end
