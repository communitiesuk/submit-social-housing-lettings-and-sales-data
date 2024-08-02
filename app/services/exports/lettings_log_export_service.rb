module Exports
  class LettingsLogExportService
    include Exports::LettingsLogExportConstants
    include CollectionTimeHelper

    def initialize(storage_service, start_time, logger = Rails.logger)
      @storage_service = storage_service
      @logger = logger
      @start_time = start_time
    end

    def export_xml_lettings_logs(full_update: false, collection_year: nil)
      archives_for_manifest = {}
      recent_export = Export.order("started_at").last
      collection_years_to_export(collection_year).each do |collection|
        base_number = Export.where(empty_export: false, collection:).maximum(:base_number) || 1
        export = build_export_run(collection, base_number, full_update)
        archives = write_export_archive(export, collection, recent_export, full_update)

        archives_for_manifest.merge!(archives)

        export.empty_export = archives.empty?
        export.save!
      end

      archives_for_manifest
    end

  private

    def build_export_run(collection, base_number, full_update)
      @logger.info("Building export run for #{collection}")
      previous_exports_with_data = Export.where(collection:, empty_export: false)

      increment_number = previous_exports_with_data.where(base_number:).maximum(:increment_number) || 1

      if full_update
        base_number += 1 if Export.any? # Only increment when it's not the first run
        increment_number = 1
      else
        increment_number += 1
      end

      if previous_exports_with_data.empty?
        return Export.new(collection:, base_number:, started_at: @start_time)
      end

      Export.new(collection:, started_at: @start_time, base_number:, increment_number:)
    end

    def get_archive_name(collection, base_number, increment)
      return unless collection

      base_number_str = "f#{base_number.to_s.rjust(4, '0')}"
      increment_str = "inc#{increment.to_s.rjust(4, '0')}"
      "core_#{collection}_#{collection + 1}_apr_mar_#{base_number_str}_#{increment_str}".downcase
    end

    def write_export_archive(export, collection, recent_export, full_update)
      archive = get_archive_name(collection, export.base_number, export.increment_number) # archive name would be the same for all logs because they're already filtered by year (?)

      initial_logs_count = retrieve_lettings_logs(recent_export, full_update).filter_by_year(collection).count
      @logger.info("Creating #{archive} - #{initial_logs_count} logs")
      return {} if initial_logs_count.zero?

      zip_file = Zip::File.open_buffer(StringIO.new)

      part_number = 1
      last_processed_marker = nil
      logs_count_after_export = 0

      loop do
        lettings_logs_slice = if last_processed_marker.present?
                                retrieve_lettings_logs(recent_export, full_update).filter_by_year(collection)
                                      .where("created_at > ?", last_processed_marker)
                                      .order(:created_at)
                                      .limit(MAX_XML_RECORDS).to_a
                              else
                                retrieve_lettings_logs(recent_export, full_update).filter_by_year(collection)
                                .order(:created_at)
                                .limit(MAX_XML_RECORDS).to_a
                              end

        break if lettings_logs_slice.empty?

        data_xml = build_export_xml(lettings_logs_slice)
        part_number_str = "pt#{part_number.to_s.rjust(3, '0')}"
        zip_file.add("#{archive}_#{part_number_str}.xml", data_xml)
        part_number += 1
        last_processed_marker = lettings_logs_slice.last.created_at
        logs_count_after_export += lettings_logs_slice.count
        @logger.info("Added #{archive}_#{part_number_str}.xml")
      end

      manifest_xml = build_manifest_xml(logs_count_after_export)
      zip_file.add("manifest.xml", manifest_xml)

      # Required by S3 to avoid Aws::S3::Errors::BadDigest
      zip_io = zip_file.write_buffer
      zip_io.rewind
      @logger.info("Writing #{archive}.zip")
      @storage_service.write_file("#{archive}.zip", zip_io)
      { archive => Time.zone.now }
    end

    def retrieve_lettings_logs(recent_export, full_update)
      if !full_update && recent_export
        params = { from: recent_export.started_at, to: @start_time }
        LettingsLog.exportable.where("(updated_at >= :from AND updated_at <= :to) OR (values_updated_at IS NOT NULL AND values_updated_at >= :from AND values_updated_at <= :to)", params)
      else
        params = { to: @start_time }
        LettingsLog.exportable.where("updated_at <= :to", params)
      end
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
      attribute_hash["discarded_at"] = lettings_log.discarded_at&.iso8601

      attribute_hash["cbl"] = 2 if attribute_hash["cbl"]&.zero?
      attribute_hash["cap"] = 2 if attribute_hash["cap"]&.zero?
      attribute_hash["chr"] = 2 if attribute_hash["chr"]&.zero?
      attribute_hash["accessible_register"] = 2 if attribute_hash["accessible_register"]&.zero?

      # Age refused
      (1..8).each do |index|
        attribute_hash["age#{index}"] = -9 if attribute_hash["age#{index}_known"] == 1
      end

      attribute_hash["log_id"] = lettings_log.id
      attribute_hash["assigned_to"] = lettings_log.assigned_to&.email
      attribute_hash["created_by"] = lettings_log.created_by&.email
      attribute_hash["amended_by"] = lettings_log.updated_by&.email

      attribute_hash["la"] = lettings_log.la
      attribute_hash["postcode_full"] = lettings_log.postcode_full

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

      # details unknown fields
      (2..8).each do |index|
        next unless lettings_log["details_known_#{index}"] == 1

        attribute_hash["age#{index}"] = -9
        attribute_hash["sex#{index}"] = "R"
        attribute_hash["relat#{index}"] = "R"
        attribute_hash["ecstat#{index}"] = 10
      end

      attribute_hash["renttype_detail"] = LettingsLog::RENTTYPE_DETAIL_MAPPING[lettings_log.rent_type] if lettings_log.rent_type.present?

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
      attribute_hash["scheme"] = scheme.id
      attribute_hash["scheme_status"] = scheme.status_at(attribute_hash["startdate"])
    end

    def add_location_fields!(location, attribute_hash)
      attribute_hash["mobstand"] = location.mobility_type_before_type_cast
      attribute_hash["scheme_old"] = location.old_visible_id
      attribute_hash["units"] = location.units
      attribute_hash["location_code"] = location.id
      attribute_hash["location_status"] = location.status_at(attribute_hash["startdate"])
    end

    def is_omitted_field?(field_name, lettings_log)
      pattern_age = /age\d_known/
      details_known_prefix = "details_known_"
      field_name.starts_with?(details_known_prefix) ||
        pattern_age.match(field_name) ||
        !EXPORT_FIELDS.include?(field_name) ||
        (lettings_log.form.start_year_after_2024? && PRE_2024_EXPORT_FIELDS.include?(field_name)) ||
        (!lettings_log.form.start_year_after_2024? && POST_2024_EXPORT_FIELDS.include?(field_name))
    end

    def build_export_xml(lettings_logs)
      doc = Nokogiri::XML("<forms/>")

      lettings_logs.each do |lettings_log|
        attribute_hash = apply_cds_transformation(lettings_log, EXPORT_MODE[:xml])
        form = doc.create_element("form")
        doc.at("forms") << form
        attribute_hash.each do |key, value|
          if is_omitted_field?(key, lettings_log)
            next
          else
            form << doc.create_element(key, value)
          end
        end
        form << doc.create_element("providertype", lettings_log.owning_organisation&.read_attribute_before_type_cast(:provider_type))
      end

      xml_doc_to_temp_file(doc)
    end

    def collection_years_to_export(collection_year)
      return [collection_year] if collection_year.present?

      FormHandler.instance.lettings_forms.values.map { |f| f.start_date.year }.uniq
    end
  end
end
