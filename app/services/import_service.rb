class ImportService
  PROVIDER_TYPE = {
    "HOUSING-ASSOCIATION" => "PRP",
  }.freeze

  def initialize(storage_service, logger = Rails.logger)
    @storage_service = storage_service
    @logger = logger
  end

  def update_organisations(folder)
    filenames = @storage_service.list_files(folder)
    filenames.each do |filename|
      file_io = @storage_service.get_file_io(filename)
      xml_document = Nokogiri::XML(file_io)
      create_organisation(xml_document)
    end
  end

private

  def create_organisation(xml_document)
    namespace = "institution"
    name = field_value(xml_document, namespace, "name")
    old_visible_id = field_value(xml_document, namespace, "visible-id")

    begin
      Organisation.create!(
        name: name,
        providertype: map_provider_type(field_value(xml_document, namespace, "institution-type")),
        phone: field_value(xml_document, namespace, "telephone-number"),
        holds_own_stock: to_boolean(field_value(xml_document, namespace, "holds-stock")),
        active: to_boolean(field_value(xml_document, namespace, "active")),
        old_association_type: field_value(xml_document, namespace, "old-association-type"),
        software_supplier_id: field_value(xml_document, namespace, "software-supplier-id"),
        housing_management_system: field_value(xml_document, namespace, "housing-management-system"),
        choice_based_lettings: to_boolean(field_value(xml_document, namespace, "choice-based-lettings")),
        common_housing_register: to_boolean(field_value(xml_document, namespace, "common-housing-register")),
        choice_allocation_policy: to_boolean(field_value(xml_document, namespace, "choice-allocation-policy")),
        cbl_proportion_percentage: field_value(xml_document, namespace, "cbl-proportion-percentage"),
        enter_affordable_logs: to_boolean(field_value(xml_document, namespace, "enter-affordable-logs")),
        owns_affordable_logs: to_boolean(field_value(xml_document, namespace, "owns-affordable-rent")),
        housing_registration_no: field_value(xml_document, namespace, "housing-registration-no"),
        general_needs_units: field_value(xml_document, namespace, "general-needs-units"),
        supported_housing_units: field_value(xml_document, namespace, "supported-housing-units"),
        unspecified_units: field_value(xml_document, namespace, "unspecified-units"),
        old_org_id: field_value(xml_document, namespace, "id"),
        old_visible_id: old_visible_id,
      )
    rescue ActiveRecord::RecordNotUnique
      @logger.warn("Organisation #{name} is already present with old visible ID #{old_visible_id}, skipping.")
    end
  end

  def map_provider_type(institution_type)
    if PROVIDER_TYPE.key?(institution_type)
      PROVIDER_TYPE[institution_type]
    else
      institution_type
    end
  end

  def field_value(xml_document, namespace, field)
    xml_document.at_xpath("//#{namespace}:#{field}")&.text
  end

  def to_boolean(input_string)
    input_string == "true"
  end
end
