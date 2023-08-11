module Imports
  class DataProtectionConfirmationImportService < ImportService
    def create_data_protection_confirmations(folder)
      import_from(folder, :create_data_protection_confirmation)
    end

  private

    def create_data_protection_confirmation(xml_document)
      org = Organisation.find_by(old_org_id: record_field_value(xml_document, "institution"))

      return log_org_must_exist if org.blank?
      return log_dpc_already_present(org) if org.data_protection_confirmed?

      dp_officer = User.find_by(
        name: record_field_value(xml_document, "dp-user"),
        organisation: org,
        is_dpo: true,
      )

      if dp_officer.blank?
        dp_officer = User.new(
          name: record_field_value(xml_document, "dp-user"),
          organisation: org,
          is_dpo: true,
          encrypted_password: SecureRandom.hex(10),
          email: SecureRandom.uuid,
          confirmed_at: Time.zone.now,
          active: false,
        )
        dp_officer.save!(validate: false)
      end

      DataProtectionConfirmation.create!(
        organisation: org,
        confirmed: record_field_value(xml_document, "data-protection").casecmp("true").zero?,
        data_protection_officer: dp_officer,
        old_id: record_field_value(xml_document, "id"),
        old_org_id: record_field_value(xml_document, "institution"),
        signed_at: record_field_value(xml_document, "change-date").to_time(:utc),
        organisation_name: org.name,
        organisation_address: org.address_row,
        organisation_phone_number: org.phone,
        data_protection_officer_email: dp_officer.email,
        data_protection_officer_name: dp_officer.name,
      )
    end

    def record_field_value(xml_document, field)
      field_value(xml_document, "dataprotect", field)
    end

    def log_dpc_already_present(org)
      # Continue
    end

    def log_org_must_exist
      @logger.error("Organisation must exist")
    end
  end
end
