module Exports
  class XmlExportService
    include Exports::LettingsLogExportConstants
    include CollectionTimeHelper

    def initialize(storage_service, start_time, logger = Rails.logger)
      @storage_service = storage_service
      @logger = logger
      @start_time = start_time
    end

  private

    def build_export_run(collection, base_number, full_update, year = nil)
      @logger.info("Building export run for #{[collection, year].join(' ')}")
      previous_exports_with_data = Export.where(collection:, year:, empty_export: false)

      increment_number = previous_exports_with_data.where(base_number:).maximum(:increment_number) || 1

      if full_update
        base_number += 1 if Export.any? # Only increment when it's not the first run
        increment_number = 1
      else
        increment_number += 1
      end

      if previous_exports_with_data.empty?
        return Export.new(collection:, year:, base_number:, started_at: @start_time)
      end

      Export.new(collection:, year:, started_at: @start_time, base_number:, increment_number:)
    end

    def write_export_archive(export, year, recent_export, full_update)
      archive = get_archive_name(year, export.base_number, export.increment_number) # archive name would be the same for all logs because they're already filtered by year (?)

      initial_count = retrieve_resources(recent_export, full_update, year).count
      @logger.info("Creating #{archive} - #{initial_count} resources")
      return {} if initial_count.zero?

      zip_file = Zip::File.open_buffer(StringIO.new)

      part_number = 1
      last_processed_marker = nil
      count_after_export = 0

      loop do
        slice = if last_processed_marker.present?
                  retrieve_resources(recent_export, full_update, year)
                        .where("created_at > ?", last_processed_marker)
                        .order(:created_at)
                        .limit(MAX_XML_RECORDS).to_a
                else
                  retrieve_resources(recent_export, full_update, year)
                  .order(:created_at)
                  .limit(MAX_XML_RECORDS).to_a
                end

        break if slice.empty?

        data_xml = build_export_xml(slice)
        part_number_str = "pt#{part_number.to_s.rjust(3, '0')}"
        zip_file.add("#{archive}_#{part_number_str}.xml", data_xml)
        part_number += 1
        last_processed_marker = slice.last.created_at
        count_after_export += slice.count
        @logger.info("Added #{archive}_#{part_number_str}.xml")
      end

      manifest_xml = build_manifest_xml(count_after_export)
      zip_file.add("manifest.xml", manifest_xml)

      # Required by S3 to avoid Aws::S3::Errors::BadDigest
      zip_io = zip_file.write_buffer
      zip_io.rewind
      @logger.info("Writing #{archive}.zip")
      @storage_service.write_file("#{archive}.zip", zip_io)
      { archive => Time.zone.now }
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
  end
end
