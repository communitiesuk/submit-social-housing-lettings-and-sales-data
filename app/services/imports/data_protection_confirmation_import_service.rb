module Imports
  class DataProtectionConfirmationImportService < ImportService
    def create_data_protection_confirmations(folder)
      import_from(folder, :create_data_protection_confirmation)
    end

  private

    def create_data_protection_confirmation(xml_document)
      org = Organisation.find_by(old_org_id: record_field_value(xml_document, "institution"))
      dp_officer = User.find_by(
        name: record_field_value(xml_document, "dp-user"),
        organisation: org,
        role: "data_protection_officer",
      )

      if dp_officer.blank?
        dp_officer = User.new(
          name: record_field_value(xml_document, "dp-user"),
          organisation: org,
          role: "data_protection_officer",
          encrypted_password: SecureRandom.hex(10),
        )
        dp_officer.save!(validate: false)
      end

      DataProtectionConfirmation.create!(
        organisation: org,
        confirmed: record_field_value(xml_document, "data-protection").casecmp("true").zero?,
        data_protection_officer: dp_officer,
        old_id: record_field_value(xml_document, "id"),
        old_org_id: record_field_value(xml_document, "institution"),
        created_at: record_field_value(xml_document, "change-date").to_time(:utc),
      )
    rescue ActiveRecord::RecordNotUnique
      id = record_field_value(xml_document, "id")
      dp_officer_name = record_field_value(xml_document, "dp-user")
      @logger.warn("Data protection confirmation #{id} created by #{dp_officer_name} for #{org.name} is already present, skipping.")
    end

    def record_field_value(xml_document, field)
      field_value(xml_document, "dataprotect", field)
    end
  end
end
