class BulkUpdateFromCsv::UpdateLocationsFromCsvService
  def initialize(original_file_name:, updated_file_name:)
    @original_file_name = original_file_name
    @updated_file_name = updated_file_name
  end

  def call
    s3_service = Storage::S3Service.new(Configuration::EnvConfigurationService.new, ENV["CSV_DOWNLOAD_PAAS_INSTANCE"])

    original_locations_csv = csv_from_path(@original_file_name, s3_service)
    updated_locations_csv = csv_from_path(@updated_file_name, s3_service)

    updated_locations_csv.each do |row|
      updated_attributes = attributes_from_row(row)

      original_row = original_locations_csv.find { |original_locations_row| original_locations_row[1] == updated_attributes["location_code"] }
      if original_row.blank? || original_row["location_code"].nil?
        Rails.logger.info("Location with id #{updated_attributes['location_code']} is not in the original location csv")
        next
      end

      original_attributes = attributes_from_row(original_row)

      location = Location.find_by(id: original_attributes["location_code"])
      if location.blank?
        Rails.logger.info("Location with id #{original_attributes['location_code']} is not in the database")
        next
      end

      updated_attributes.each do |key, value|
        next unless value != original_attributes[key] && value.present?

        case key
        when "location_admin_district"
          update_location_admin_district(location, original_attributes, value)
        when "postcode"
          update_postcode(location, original_attributes, value)
        when "scheme_code"
          update_scheme(location, original_attributes, value)
        when "name", "units", "type_of_unit", "mobility_type"
          begin
            location[key] = value
            Rails.logger.info("Updating location #{original_attributes['location_code']} with #{key}: #{value}")
          rescue ArgumentError => e
            Rails.logger.info("Cannot update location #{original_attributes['location_code']} with #{key}: #{value}. #{e.message}")
          end
        when "location_code", "status", "active_dates"
          Rails.logger.info("Cannot update location #{original_attributes['location_code']} with #{key} as it it not a permitted field")
        end
      end

      unless location.changed?
        Rails.logger.info("No changes to location #{original_attributes['location_code']}.")
        next
      end

      save_location(location, original_attributes)
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
    attributes["location_code"] = row[1]
    attributes["postcode"] = row[2]
    attributes["name"] = row[3]
    attributes["status"] = row[4]
    attributes["location_admin_district"] = row[5]
    attributes["units"] = row[6]
    attributes["type_of_unit"] = row[7]
    attributes["mobility_type"] = row[8]
    attributes["active_dates"] = row[9]
    attributes
  end

  def update_location_admin_district(location, original_attributes, value)
    location_code = Location.local_authorities_for_current_year.key(value)
    if location_code.present?
      location.location_code = location_code
      location.location_admin_district = value
      Rails.logger.info("Updating location #{original_attributes['location_code']} with location_code: #{location_code}")
    else
      Rails.logger.info("Cannot update location #{original_attributes['location_code']} with location_admin_district: #{value}. Location admin distrint #{value} is not a valid option")
    end
  end

  def update_postcode(location, original_attributes, value)
    if !value&.match(POSTCODE_REGEXP)
      Rails.logger.info("Cannot update location #{original_attributes['location_code']} with postcode: #{value}. #{I18n.t('validations.postcode')}")
    else
      location.postcode = PostcodeService.clean(value)
      Rails.logger.info("Updating location #{original_attributes['location_code']} with postcode: #{value}")
    end
  end

  def update_scheme(location, original_attributes, value)
    scheme = Scheme.find_by(id: value.delete("S"))
    if scheme.present?
      original_scheme = Scheme.find_by(id: original_attributes["scheme_code"].delete("S"))
      if original_scheme.nil? || !([original_scheme.owning_organisation] + original_scheme.owning_organisation.parent_organisations + original_scheme.owning_organisation.child_organisations).include?(scheme.owning_organisation)
        Rails.logger.info("Cannot update location #{original_attributes['location_code']} with scheme_code: #{value}. Scheme with id #{value} is not in organisation that does not have relationship with the original organisation")
      else
        location["scheme_id"] = scheme.id
        Rails.logger.info("Updating location #{original_attributes['location_code']} with scheme: S#{scheme.id}")
        editable_from_date = FormHandler.instance.earliest_open_for_editing_collection_start_date
        editable_logs = LettingsLog.where(location_id: location.id).after_date(editable_from_date)
        editable_logs.update!(location: nil, scheme: nil, values_updated_at: Time.zone.now)
        Rails.logger.info("Cleared location and scheme for logs with startdate and location #{location.id}. Log IDs: #{editable_logs.map(&:id).join(', ')}")

        logs_without_start_date = LettingsLog.where(scheme_id: scheme.id).where(startdate: nil)
        logs_without_start_date.update!(location: nil, scheme: nil, values_updated_at: Time.zone.now)
        Rails.logger.info("Cleared location and scheme for logs without startdate and location #{location.id}. Log IDs: #{logs_without_start_date.map(&:id).join(', ')}")

        exportable_from_date = FormHandler.instance.previous_collection_start_date
        remaining_logs_to_export = LettingsLog.where(location_id: location.id).after_date(exportable_from_date)
        remaining_logs_to_export.update_all(location_id: nil, scheme_id: nil, values_updated_at: Time.zone.now)
        Rails.logger.info("Cleared location and scheme for non editable logs with location #{location.id}. Log IDs: #{remaining_logs_to_export.map(&:id).join(', ')}")
      end
    else
      Rails.logger.info("Cannot update location #{original_attributes['location_code']} with scheme_code: #{value}. Scheme with id #{value} is not in the database")
    end
  end

  def save_location(location, original_attributes)
    location.save!
    Rails.logger.info("Saved location #{original_attributes['location_code']}.")
    exportable_from_date = FormHandler.instance.previous_collection_start_date
    logs_to_export = LettingsLog.where(location_id: location.id).after_date(exportable_from_date)
    if original_attributes["location_admin_district"] != location.location_admin_district
      clear_invalid_rent_fields(logs_to_export)
    else
      logs_to_export.update_all(values_updated_at: Time.zone.now)
    end

    logs_not_to_export = LettingsLog.where(location_id: location.id).before_date(exportable_from_date)
    Rails.logger.info("Will not export log #{logs_not_to_export.map(&:id).join(',')} as it is before the exportable date") if logs_not_to_export.any?
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error("Cannot update location #{original_attributes['location_code']}. #{e.message}")
  end

  def clear_invalid_rent_fields(logs)
    logs.each do |log|
      if log.rent_in_soft_min_range? || log.rent_in_soft_max_range?
        complete_or_log_soft_invalidated_log(log)
      else
        log.validate
        if log.errors["brent"].any?
          Rails.logger.info("Log #{log.id} went from completed to in progress.") if log.status == "completed"
          log.brent = nil
          log.scharge = nil
          log.pscharge = nil
          log.supcharg = nil
        end
        log.values_updated_at = Time.zone.now
        log.save!(validate: false)
      end
    end
  end

  def complete_or_log_soft_invalidated_log(log)
    return if log.rent_value_check.present?

    editable_from_date = FormHandler.instance.earliest_open_for_editing_collection_start_date
    if log.startdate < editable_from_date
      log.rent_value_check = 0
      Rails.logger.info("Confirmed rent value check for log #{log.id}.")
    elsif log.status == "completed"
      Rails.logger.info("Log #{log.id} went from completed to in progress.")
    else
      Rails.logger.info("Log #{log.id} stayed in progress, triggering soft rent value check.")
    end
    log.values_updated_at = Time.zone.now
    log.save!(validate: false)
  end
end
