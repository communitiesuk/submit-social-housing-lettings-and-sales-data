class BulkUpdateFromCsv::UpdateSchemesFromCsvService
  def initialize(original_file_name:, updated_file_name:)
    @original_file_name = original_file_name
    @updated_file_name = updated_file_name
  end

  def call
    s3_service = Storage::S3Service.new(Configuration::EnvConfigurationService.new, ENV["CSV_DOWNLOAD_PAAS_INSTANCE"])

    original_schemes_csv = csv_from_path(@original_file_name, s3_service)
    updated_schemes_csv = csv_from_path(@updated_file_name, s3_service)

    updated_schemes_csv.each do |row|
      updated_attributes = attributes_from_row(row)

      original_row = original_schemes_csv.find { |original_schemes_row| original_schemes_row[0] == updated_attributes["scheme_code"] }
      if original_row.blank? || original_row["scheme_code"].nil?
        Rails.logger.info("Scheme with id #{updated_attributes['scheme_code']} is not in the original scheme csv")
        next
      end

      original_attributes = attributes_from_row(original_row)

      scheme = Scheme.find_by(id: original_attributes["scheme_code"].delete("S"))
      if scheme.blank?
        Rails.logger.info("Scheme with id #{original_attributes['scheme_code']} is not in the database")
        next
      end

      updated_attributes.each do |key, value|
        next unless value != original_attributes[key] && value.present?

        case key
        when "owning_organisation"
          update_owning_organisation(scheme, original_attributes, value)
        when "service_name", "sensitive", "scheme_type", "registered_under_care_act", "arrangement_type", "primary_client_group", "has_other_client_group", "secondary_client_group", "support_type", "intended_stay"
          begin
            scheme[key] = value
            Rails.logger.info("Updating scheme #{original_attributes['scheme_code']} with #{key}: #{value}")
          rescue ArgumentError => e
            Rails.logger.info("Cannot update scheme #{original_attributes['scheme_code']} with #{key}: #{value}. #{e.message}")
          end
        when "scheme_code", "status", "created_at", "active_dates"
          Rails.logger.info("Cannot update scheme #{original_attributes['scheme_code']} with #{key} as it it not a permitted field")
        end
      end

      unless scheme.changed?
        Rails.logger.info("No changes to scheme #{original_attributes['scheme_code']}.")
        next
      end

      save_scheme(scheme, original_attributes)
    end
  end

private

  def csv_from_path(path, s3_service)
    original_file_io = s3_service.get_file_io(path)
    original_file_io.set_encoding_by_bom
    CSV.parse(original_file_io, headers: true)
  end

  def attributes_from_row(row)
    attributes = {}

    attributes["scheme_code"] = row[0]
    attributes["service_name"] = row[1]
    attributes["status"] = row[2]
    attributes["sensitive"] = row[3]
    attributes["scheme_type"] = row[4]
    attributes["registered_under_care_act"] = row[5]
    attributes["owning_organisation"] = row[6]
    attributes["arrangement_type"] = row[7]
    attributes["primary_client_group"] = row[8]
    attributes["has_other_client_group"] = row[9]
    attributes["secondary_client_group"] = row[10]
    attributes["support_type"] = row[11]
    attributes["intended_stay"] = row[12]
    attributes["created_at"] = row[13]
    attributes["active_dates"] = row[14]
    attributes
  end

  def update_owning_organisation(scheme, original_attributes, value)
    current_organisation = scheme.owning_organisation
    organisation = Organisation.find_by(name: value)
    if organisation.present? && (organisation.child_organisations.include?(current_organisation) || organisation.parent_organisations.include?(current_organisation))
      scheme["owning_organisation_id"] = organisation.id
      Rails.logger.info("Updating scheme #{original_attributes['scheme_code']} with owning_organisation: #{organisation.name}")
      LettingsLog.where(scheme_id: scheme.id).update!(location: nil, scheme: nil, unresolved: true)
    else
      Rails.logger.info("Cannot update scheme #{original_attributes['scheme_code']} with owning_organisation: #{value}. Organisation with name #{value} is not in the database or is not related to current organisation")
    end
  end

  def save_scheme(scheme, original_attributes)
    scheme.save!
    Rails.logger.info("Saved scheme #{original_attributes['scheme_code']}.")
    LettingsLog.where(scheme_id: scheme.id).update_all(values_updated_at: Time.zone.now)
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error("Cannot update scheme #{original_attributes['scheme_code']}. #{e.message}")
  end
end
