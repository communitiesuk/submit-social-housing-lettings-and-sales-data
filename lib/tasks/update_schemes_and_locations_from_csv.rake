namespace :bulk_update do
  desc "Bulk update scheme data from a csv file"
  task :update_schemes_from_csv, %i[original_file_name updated_file_name] => :environment do |_task, args|
    original_file_name = args[:original_file_name]
    updated_file_name = args[:updated_file_name]

    raise "Usage: rake bulk_update:update_schemes_from_csv['original_file_name','updated_file_name']" if original_file_name.blank? || updated_file_name.blank?

    s3_service = Storage::S3Service.new(Configuration::EnvConfigurationService.new, ENV["CSV_DOWNLOAD_PAAS_INSTANCE"])
    original_file_io = s3_service.get_file_io(original_file_name)
    original_file_io.set_encoding_by_bom
    original_schemes_csv = CSV.parse(original_file_io, headers: true)

    updated_file_io = s3_service.get_file_io(updated_file_name)
    updated_file_io.set_encoding_by_bom
    updated_schemes_csv = CSV.parse(updated_file_io, headers: true)

    updated_schemes_csv.each do |row|
      original_attributes = {}
      updated_attributes = {}

      updated_attributes["scheme_code"] = row[0]
      updated_attributes["service_name"] = row[1]
      updated_attributes["status"] = row[2]
      updated_attributes["sensitive"] = row[3]
      updated_attributes["scheme_type"] = row[4]
      updated_attributes["registered_under_care_act"] = row[5]
      updated_attributes["owning_organisation_name"] = row[6]
      updated_attributes["arrangement_type"] = row[7]
      updated_attributes["primary_client_group"] = row[8]
      updated_attributes["has_other_client_group"] = row[9]
      updated_attributes["secondary_client_group"] = row[10]
      updated_attributes["support_type"] = row[11]
      updated_attributes["intended_stay"] = row[12]
      updated_attributes["created_at"] = row[13]
      updated_attributes["active_dates"] = row[14]

      original_row = original_schemes_csv.find { |original_schemes_row| original_schemes_row[0] == updated_attributes["scheme_code"] }
      if original_row.blank? || original_row["scheme_code"].nil?
        Rails.logger.info("Scheme with id #{updated_attributes['scheme_code']} is not in the original scheme csv")
        next
      end

      original_attributes["scheme_code"] = original_row[0]
      original_attributes["service_name"] = original_row[1]
      original_attributes["status"] = original_row[2]
      original_attributes["sensitive"] = original_row[3]
      original_attributes["scheme_type"] = original_row[4]
      original_attributes["registered_under_care_act"] = original_row[5]
      original_attributes["owning_organisation_name"] = original_row[6]
      original_attributes["arrangement_type"] = original_row[7]
      original_attributes["primary_client_group"] = original_row[8]
      original_attributes["has_other_client_group"] = original_row[9]
      original_attributes["secondary_client_group"] = original_row[10]
      original_attributes["support_type"] = original_row[11]
      original_attributes["intended_stay"] = original_row[12]
      original_attributes["created_at"] = original_row[13]
      original_attributes["active_dates"] = original_row[14]

      scheme = Scheme.find_by(id: original_attributes["scheme_code"].delete("S"))
      if scheme.blank?
        Rails.logger.info("Scheme with id #{original_attributes['scheme_code']} is not in the database")
        next
      end

      updated_attributes.each do |key, value|
        next unless value != original_attributes[key] && value.present?

        case key
        when "service_name", "sensitive", "scheme_type", "registered_under_care_act", "arrangement_type", "primary_client_group", "has_other_client_group", "secondary_client_group", "support_type", "intended_stay"
          begin
            scheme[key] = value
            Rails.logger.info("Updating scheme #{original_attributes['scheme_code']}, with #{key}: #{value}")
          rescue ArgumentError => e
            Rails.logger.info("Cannot update scheme #{original_attributes['scheme_code']} with #{key}: #{value}. #{e.message}")
          end
        when "owning_organisation_name"
          organisation = Organisation.find_by(name: value)
          if organisation.present?
            scheme["owning_organisation_id"] = organisation.id
            Rails.logger.info("Updating scheme #{original_attributes['scheme_code']}, with owning_organisation: #{organisation.name}")
          else
            Rails.logger.info("Cannot update scheme #{original_attributes['scheme_code']} with #{key}: #{value}. Organisation with name #{value} is not in the database")
          end
        when "scheme_code", "status", "created_at", "active_dates"
          Rails.logger.info("Cannot update scheme #{original_attributes['scheme_code']} with #{key} as it it not a permitted field")
        end
      end

      unless scheme.changed?
        Rails.logger.info("No changes to scheme #{original_attributes['scheme_code']}.")
        next
      end

      begin
        scheme.save!
        Rails.logger.info("Saved scheme #{original_attributes['scheme_code']}.")
        LettingsLog.where(scheme_id: scheme.id).update_all(values_updated_at: Time.zone.now)
      rescue ActiveRecord::RecordInvalid => e
        Rails.logger.error("Cannot update scheme #{original_attributes['scheme_code']}. #{e.message}")
      end
    end
  end

  desc "Bulk update location data from a csv file"
  task :update_locations_from_csv, %i[original_file_name updated_file_name] => :environment do |_task, args|
    original_file_name = args[:original_file_name]
    updated_file_name = args[:updated_file_name]

    raise "Usage: rake bulk_update:update_locations_from_csv['original_file_name','updated_file_name']" if original_file_name.blank? || updated_file_name.blank?

    s3_service = Storage::S3Service.new(Configuration::EnvConfigurationService.new, ENV["CSV_DOWNLOAD_PAAS_INSTANCE"])
    original_file_io = s3_service.get_file_io(original_file_name)
    original_file_io.set_encoding_by_bom
    original_locations_csv = CSV.parse(original_file_io, headers: true)

    updated_file_io = s3_service.get_file_io(updated_file_name)
    updated_file_io.set_encoding_by_bom
    updated_locations_csv = CSV.parse(updated_file_io, headers: true)

    updated_locations_csv.each do |row|
      original_attributes = {}
      updated_attributes = {}

      updated_attributes["scheme_code"] = row[0]
      updated_attributes["location_code"] = row[1]
      updated_attributes["postcode"] = row[2]
      updated_attributes["name"] = row[3]
      updated_attributes["status"] = row[4]
      updated_attributes["location_admin_district"] = row[5]
      updated_attributes["units"] = row[6]
      updated_attributes["type_of_unit"] = row[7]
      updated_attributes["mobility_type"] = row[8]
      updated_attributes["active_dates"] = row[9]

      original_row = original_locations_csv.find { |original_locations_row| original_locations_row[1] == updated_attributes["location_code"] }
      if original_row.blank? || original_row["location_code"].nil?
        Rails.logger.info("Location with id #{updated_attributes['location_code']} is not in the original location csv")
        next
      end

      original_attributes["scheme_code"] = original_row[0]
      original_attributes["location_code"] = original_row[1]
      original_attributes["postcode"] = original_row[2]
      original_attributes["name"] = original_row[3]
      original_attributes["status"] = original_row[4]
      original_attributes["location_admin_district"] = original_row[5]
      original_attributes["units"] = original_row[6]
      original_attributes["type_of_unit"] = original_row[7]
      original_attributes["mobility_type"] = original_row[8]
      original_attributes["active_dates"] = original_row[9]

      location = Location.find_by(id: original_attributes["location_code"])
      if location.blank?
        Rails.logger.info("Location with id #{original_attributes['location_code']} is not in the database")
        next
      end

      updated_attributes.each do |key, value|
        next unless value != original_attributes[key] && value.present?

        case key
        when "location_admin_district"
          location_code = Location.local_authorities_for_current_year.key(value)
          if location_code.present?
            location.location_code = location_code
            location.location_admin_district = value
            Rails.logger.info("Updating location #{original_attributes['location_code']}, with location_code: #{location_code}")
          else
            Rails.logger.info("Cannot update location #{original_attributes['location_code']} with #{key}: #{value}. Location admin distrint #{value} is not a valid option")
          end
        when "postcode"
          if !value&.match(POSTCODE_REGEXP)
            Rails.logger.info("Cannot update location #{original_attributes['location_code']} with #{key}: #{value}. #{I18n.t('validations.postcode')}")
          else
            location.postcode = PostcodeService.clean(value)
            Rails.logger.info("Updating location #{original_attributes['location_code']}, with postcode: #{value}")
          end
        when "name", "units", "type_of_unit", "mobility_type"
          begin
            location[key] = value
            Rails.logger.info("Updating location #{original_attributes['location_code']}, with #{key}: #{value}")
          rescue ArgumentError => e
            Rails.logger.info("Cannot update location #{original_attributes['location_code']} with #{key}: #{value}. #{e.message}")
          end
        when "scheme_code"
          scheme = Scheme.find_by(id: value.delete("S"))
          if scheme.present?
            location["scheme_id"] = scheme.id
            Rails.logger.info("Updating location #{original_attributes['location_code']}, with scheme: S#{scheme.id}")
          else
            Rails.logger.info("Cannot update location #{original_attributes['location_code']} with #{key}: #{value}. Scheme with id #{value} is not in the database")
          end
        when "location_code", "status", "active_dates"
          Rails.logger.info("Cannot update location #{original_attributes['location_code']} with #{key} as it it not a permitted field")
        end
      end

      unless location.changed?
        Rails.logger.info("No changes to location #{original_attributes['location_code']}.")
        next
      end

      begin
        location.save!
        Rails.logger.info("Saved location #{original_attributes['location_code']}.")
        LettingsLog.where(location_id: location.id).update_all(values_updated_at: Time.zone.now)
      rescue ActiveRecord::RecordInvalid => e
        Rails.logger.error("Cannot update location #{original_attributes['location_code']}. #{e.message}")
      end
    end
  end
end
