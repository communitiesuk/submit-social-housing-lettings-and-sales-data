module Imports
  class OrganisationImportService < ImportService
    def create_organisations(folder)
      import_from(folder, :create_organisation)
    end

  private

    PROVIDER_TYPE = {
      "HOUSING-ASSOCIATION" => Organisation.org_types[:PRP],
    }.freeze

    def create_organisation(xml_document)
      Organisation.create!(
        name: organisation_field_value(xml_document, "name"),
        providertype: map_provider_type(organisation_field_value(xml_document, "institution-type")),
        phone: organisation_field_value(xml_document, "telephone-number"),
        holds_own_stock: to_boolean(organisation_field_value(xml_document, "holds-stock")),
        active: to_boolean(organisation_field_value(xml_document, "active")),
        old_association_type: organisation_field_value(xml_document, "old-association-type"),
        software_supplier_id: organisation_field_value(xml_document, "software-supplier-id"),
        housing_management_system: organisation_field_value(xml_document, "housing-management-system"),
        choice_based_lettings: to_boolean(organisation_field_value(xml_document, "choice-based-lettings")),
        common_housing_register: to_boolean(organisation_field_value(xml_document, "common-housing-register")),
        choice_allocation_policy: to_boolean(organisation_field_value(xml_document, "choice-allocation-policy")),
        cbl_proportion_percentage: organisation_field_value(xml_document, "cbl-proportion-percentage"),
        enter_affordable_logs: to_boolean(organisation_field_value(xml_document, "enter-affordable-logs")),
        owns_affordable_logs: to_boolean(organisation_field_value(xml_document, "owns-affordable-rent")),
        housing_registration_no: organisation_field_value(xml_document, "housing-registration-no"),
        general_needs_units: organisation_field_value(xml_document, "general-needs-units"),
        supported_housing_units: organisation_field_value(xml_document, "supported-housing-units"),
        unspecified_units: organisation_field_value(xml_document, "unspecified-units"),
        old_org_id: organisation_field_value(xml_document, "id"),
        old_visible_id: organisation_field_value(xml_document, "visible-id"),
      )
    rescue ActiveRecord::RecordNotUnique
      name = organisation_field_value(xml_document, "name")
      old_visible_id = organisation_field_value(xml_document, "visible-id")
      @logger.warn("Organisation #{name} is already present with old visible ID #{old_visible_id}, skipping.")
    end

    def map_provider_type(institution_type)
      if PROVIDER_TYPE.key?(institution_type)
        PROVIDER_TYPE[institution_type]
      else
        institution_type
      end
    end

    def organisation_field_value(xml_document, field)
      field_value(xml_document, "institution", field)
    end
  end
end
