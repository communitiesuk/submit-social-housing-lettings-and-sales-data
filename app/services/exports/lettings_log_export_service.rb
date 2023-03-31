module Exports
  class LettingsLogExportService
    include Exports::LettingsLogExportConstants
    include CollectionTimeHelper

    def initialize(storage_service, logger = Rails.logger)
      @storage_service = storage_service
      @logger = logger
    end

    def export_csv_lettings_logs
      time_str = Time.zone.now.strftime("%F").underscore
      lettings_logs = retrieve_lettings_logs(Time.zone.now, true)
      csv_io = build_export_csv(lettings_logs)
      @storage_service.write_file("export_#{time_str}.csv", csv_io)
    end

    def export_xml_lettings_logs(full_update: false)
      start_time = Time.zone.now
      lettings_logs = retrieve_lettings_logs(start_time, full_update)
      export = build_export_run(start_time, full_update)
      daily_run = get_daily_run_number
      archive_datetimes = write_export_archive(export, lettings_logs)
      export.empty_export = archive_datetimes.empty?
      write_master_manifest(daily_run, archive_datetimes)
      export.save!
    end

  private

    def get_daily_run_number
      today = Time.zone.today
      LogsExport.where(created_at: today.beginning_of_day..today.end_of_day).count + 1
    end

    def build_export_run(current_time, full_update)
      previous_exports_with_data = LogsExport.where(empty_export: false)

      if previous_exports_with_data.empty?
        return LogsExport.new(started_at: current_time)
      end

      base_number = previous_exports_with_data.maximum(:base_number)
      increment_number = previous_exports_with_data.where(base_number:).maximum(:increment_number)

      if full_update
        base_number += 1
        increment_number = 1
      else
        increment_number += 1
      end

      LogsExport.new(started_at: current_time, base_number:, increment_number:)
    end

    def write_master_manifest(daily_run, archive_datetimes)
      today = Time.zone.today
      increment_number = daily_run.to_s.rjust(4, "0")
      month = today.month.to_s.rjust(2, "0")
      day = today.day.to_s.rjust(2, "0")
      file_path = "Manifest_#{today.year}_#{month}_#{day}_#{increment_number}.csv"
      string_io = build_manifest_csv_io(archive_datetimes)
      @storage_service.write_file(file_path, string_io)
    end

    def get_archive_name(lettings_log, base_number, increment)
      return unless lettings_log.startdate

      collection_start = lettings_log.collection_start_year
      start_month = collection_start_date(lettings_log.startdate).strftime("%b")
      end_month = collection_end_date(lettings_log.startdate).strftime("%b")
      base_number_str = "f#{base_number.to_s.rjust(4, '0')}"
      increment_str = "inc#{increment.to_s.rjust(4, '0')}"
      "core_#{collection_start}_#{collection_start + 1}_#{start_month}_#{end_month}_#{base_number_str}_#{increment_str}".downcase
    end

    def write_export_archive(export, lettings_logs)
      # Order lettings logs per archive
      lettings_logs_per_archive = {}
      lettings_logs.each do |lettings_log|
        archive = get_archive_name(lettings_log, export.base_number, export.increment_number)
        next unless archive

        if lettings_logs_per_archive.key?(archive)
          lettings_logs_per_archive[archive] << lettings_log
        else
          lettings_logs_per_archive[archive] = [lettings_log]
        end
      end

      # Write all archives
      archive_datetimes = {}
      lettings_logs_per_archive.each do |archive, lettings_logs_to_export|
        manifest_xml = build_manifest_xml(lettings_logs_to_export.count)
        zip_file = Zip::File.open_buffer(StringIO.new)
        zip_file.add("manifest.xml", manifest_xml)

        part_number = 1
        lettings_logs_to_export.each_slice(MAX_XML_RECORDS) do |lettings_logs_slice|
          data_xml = build_export_xml(lettings_logs_slice)
          part_number_str = "pt#{part_number.to_s.rjust(3, '0')}"
          zip_file.add("#{archive}_#{part_number_str}.xml", data_xml)
          part_number += 1
        end

        # Required by S3 to avoid Aws::S3::Errors::BadDigest
        zip_io = zip_file.write_buffer
        zip_io.rewind
        @storage_service.write_file("#{archive}.zip", zip_io)
        archive_datetimes[archive] = Time.zone.now
      end

      archive_datetimes
    end

    def retrieve_lettings_logs(start_time, full_update)
      recent_export = LogsExport.order("started_at").last

      if !full_update && recent_export
        params = { from: recent_export.started_at, to: start_time }
        LettingsLog.visible.where("updated_at >= :from and updated_at <= :to", params)
      else
        params = { to: start_time }
        LettingsLog.visible.where("updated_at <= :to", params)
      end
    end

    def build_manifest_csv_io(archive_datetimes)
      headers = ["zip-name", "date-time zipped folder generated", "zip-file-uri"]
      csv_string = CSV.generate do |csv|
        csv << headers
        archive_datetimes.each do |archive, datetime|
          csv << [archive, datetime, "#{archive}.zip"]
        end
      end
      StringIO.new(csv_string)
    end

    def xml_doc_to_temp_file(xml_doc)
      file = Tempfile.new
      xml_doc.write_xml_to(file, encoding: "UTF-8")
      file.rewind
      file
    end

    def build_manifest_xml(record_number)
      doc = Nokogiri::XML("<report/>")
      doc.at("report") << doc.create_element("form-data-summary")
      doc.at("form-data-summary") << doc.create_element("records")
      doc.at("records") << doc.create_element("count-of-records", record_number)

      xml_doc_to_temp_file(doc)
    end

    def apply_cds_transformation(lettings_log, export_mode)
      attribute_hash = lettings_log.attributes_before_type_cast
      attribute_hash["formid"] = attribute_hash["old_form_id"] || (attribute_hash["id"] + LOG_ID_OFFSET)

      # We can't have a variable number of columns in CSV
      unless export_mode == EXPORT_MODE[:csv]
        case lettings_log.collection_start_year
        when 2021
          attribute_hash.delete("joint")
        when 2022
          attribute_hash.delete("underoccupation_benefitcap")
        end
      end

      # Organisation fields
      if lettings_log.owning_organisation
        attribute_hash["owningorgid"] = lettings_log.owning_organisation.old_visible_id || (lettings_log.owning_organisation.id + LOG_ID_OFFSET)
        attribute_hash["owningorgname"] = lettings_log.owning_organisation.name
        attribute_hash["hcnum"] = lettings_log.owning_organisation.housing_registration_no
      end
      if lettings_log.managing_organisation
        attribute_hash["maningorgid"] = lettings_log.managing_organisation.old_visible_id || (lettings_log.managing_organisation.id + LOG_ID_OFFSET)
        attribute_hash["maningorgname"] = lettings_log.managing_organisation.name
        attribute_hash["manhcnum"] = lettings_log.managing_organisation.housing_registration_no
      end

      # Covert date times to ISO 8601
      attribute_hash["createddate"] = lettings_log.created_at&.iso8601
      attribute_hash["uploaddate"] = lettings_log.updated_at&.iso8601
      attribute_hash["mrcdate"] = lettings_log.mrcdate&.iso8601
      attribute_hash["startdate"] = lettings_log.startdate&.iso8601
      attribute_hash["voiddate"] = lettings_log.voiddate&.iso8601

      attribute_hash["cbl"] = 2 if attribute_hash["cbl"]&.zero?
      attribute_hash["cap"] = 2 if attribute_hash["cap"]&.zero?
      attribute_hash["chr"] = 2 if attribute_hash["chr"]&.zero?

      # Age refused
      (1..8).each do |index|
        attribute_hash["age#{index}"] = -9 if attribute_hash["age#{index}_known"] == 1
      end

      # Supported housing fields
      if lettings_log.is_supported_housing?
        attribute_hash["unittype_sh"] = lettings_log.unittype_sh
        attribute_hash["sheltered"] = lettings_log.sheltered
        attribute_hash["nocharge"] = lettings_log.household_charge == 1 ? 1 : nil
        attribute_hash["chcharge"] = lettings_log.chcharge
        add_scheme_fields!(lettings_log.scheme, attribute_hash) if lettings_log.scheme
        add_location_fields!(lettings_log.location, attribute_hash) if lettings_log.location
        attribute_hash.delete("unittype_gn")
      end
      attribute_hash
    end

    def add_scheme_fields!(scheme, attribute_hash)
      attribute_hash["confidential"] = scheme.sensitive_before_type_cast == 1 ? 1 : nil
      attribute_hash["cligrp1"] = scheme.primary_client_group_before_type_cast
      attribute_hash["cligrp2"] = scheme.secondary_client_group_before_type_cast
      attribute_hash["intstay"] = scheme.intended_stay_before_type_cast
      attribute_hash["mantype"] = scheme.arrangement_type_before_type_cast
      attribute_hash["reghome"] = scheme.registered_under_care_act_before_type_cast
      attribute_hash["schtype"] = scheme.scheme_type_before_type_cast
      attribute_hash["support"] = scheme.support_type_before_type_cast
      attribute_hash["units_scheme"] = scheme.locations.map(&:units).compact.sum
    end

    def add_location_fields!(location, attribute_hash)
      attribute_hash["mobstand"] = location.mobility_type_before_type_cast
      attribute_hash["scheme"] = location.old_visible_id || (location.id + LOG_ID_OFFSET)
      attribute_hash["units"] = location.units
    end

    def filter_keys!(attributes)
      attributes.reject! { |attribute| is_omitted_field?(attribute) }
    end

    def is_omitted_field?(field_name)
      pattern_age = /age\d_known/
      details_known_prefix = "details_known_"
      field_name.starts_with?(details_known_prefix) ||
        pattern_age.match(field_name) ||
        !EXPORT_FIELDS.include?(field_name)
    end

    def build_export_csv(lettings_logs)
      csv_io = CSV.generate do |csv|
        attribute_keys = nil
        lettings_logs.each do |lettings_log|
          attribute_hash = apply_cds_transformation(lettings_log, EXPORT_MODE[:csv])
          if attribute_keys.nil?
            attribute_keys = attribute_hash.keys
            filter_keys!(attribute_keys)
            csv << attribute_keys
          end
          csv << attribute_keys.map { |attribute_key| attribute_hash[attribute_key] }
        end
      end

      StringIO.new(csv_io)
    end

    def build_export_xml(lettings_logs)
      doc = Nokogiri::XML("<forms/>")

      lettings_logs.each do |lettings_log|
        attribute_hash = apply_cds_transformation(lettings_log, EXPORT_MODE[:xml])
        form = doc.create_element("form")
        doc.at("forms") << form
        attribute_hash.each do |key, value|
          if is_omitted_field?(key)
            next
          else
            form << doc.create_element(key, value)
          end
        end
        form << doc.create_element("providertype", lettings_log.owning_organisation&.read_attribute_before_type_cast(:provider_type))
      end

      xml_doc_to_temp_file(doc)
    end
  end
end
