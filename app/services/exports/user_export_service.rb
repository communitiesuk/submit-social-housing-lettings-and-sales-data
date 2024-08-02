module Exports
  class UserExportService
    include Exports::UserExportConstants
    include CollectionTimeHelper

    def initialize(storage_service, start_time, logger = Rails.logger)
      @storage_service = storage_service
      @logger = logger
      @start_time = start_time
    end

    def export_xml_users(full_update: false)
      recent_export = Export.order("started_at").last

      collection = "users"
      base_number = Export.where(empty_export: false, collection:).maximum(:base_number) || 1
      export = build_export_run(collection, base_number, full_update)
      archives_for_manifest = write_export_archive(export, collection, recent_export, full_update)

      export.empty_export = archives_for_manifest.empty?
      export.save!

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
      "core_#{collection}_#{current_collection_start_year}_#{current_collection_start_year + 1}_apr_mar_#{base_number_str}_#{increment_str}".downcase
    end

    def write_export_archive(export, collection, recent_export, full_update)
      archive = get_archive_name(collection, export.base_number, export.increment_number)

      initial_users_count = retrieve_users(recent_export, full_update).count
      @logger.info("Creating #{archive} - #{initial_users_count} users")
      return {} if initial_users_count.zero?

      zip_file = Zip::File.open_buffer(StringIO.new)

      part_number = 1
      last_processed_marker = nil
      users_count_after_export = 0

      loop do
        users_slice = if last_processed_marker.present?
                        retrieve_users(recent_export, full_update)
                              .where("created_at > ?", last_processed_marker)
                              .order(:created_at)
                              .limit(MAX_XML_RECORDS).to_a
                      else
                        retrieve_users(recent_export, full_update)
                        .order(:created_at)
                        .limit(MAX_XML_RECORDS).to_a
                      end

        break if users_slice.empty?

        data_xml = build_export_xml(users_slice)
        part_number_str = "pt#{part_number.to_s.rjust(3, '0')}"
        zip_file.add("#{archive}_#{part_number_str}.xml", data_xml)
        part_number += 1
        last_processed_marker = users_slice.last.created_at
        users_count_after_export += users_slice.count
        @logger.info("Added #{archive}_#{part_number_str}.xml")
      end

      manifest_xml = build_manifest_xml(users_count_after_export)
      zip_file.add("manifest.xml", manifest_xml)

      # Required by S3 to avoid Aws::S3::Errors::BadDigest
      zip_io = zip_file.write_buffer
      zip_io.rewind
      @logger.info("Writing #{archive}.zip")
      @storage_service.write_file("#{archive}.zip", zip_io)
      { archive => Time.zone.now }
    end

    def retrieve_users(recent_export, full_update)
      if !full_update && recent_export
        params = { from: recent_export.started_at, to: @start_time }
        User.where("(updated_at >= :from AND updated_at <= :to)", params)
      else
        params = { to: @start_time }
        User.where("updated_at <= :to", params)
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

    def apply_cds_transformation(user)
      attribute_hash = user.attributes_before_type_cast
      attribute_hash["role"] = user.role
      attribute_hash["organisation_name"] = user.organisation.name
      attribute_hash["active"] = user.active?
      attribute_hash
    end

    def build_export_xml(users)
      doc = Nokogiri::XML("<forms/>")

      users.each do |user|
        attribute_hash = apply_cds_transformation(user)
        form = doc.create_element("form")
        doc.at("forms") << form
        attribute_hash.each do |key, value|
          if !EXPORT_FIELDS.include?(key)
            next
          else
            form << doc.create_element(key, value)
          end
        end
      end

      xml_doc_to_temp_file(doc)
    end
  end
end
