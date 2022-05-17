module Exports
  class CaseLogExportService
    QUARTERS = {
      0 => "jan_mar",
      1 => "apr_jun",
      2 => "jul_sep",
      3 => "oct_dec"
    }.freeze

    LOG_ID_OFFSET = 300_000_000_000

    def initialize(storage_service, logger = Rails.logger)
      @storage_service = storage_service
      @logger = logger
    end

    def export_case_logs
      # Case log data is already ordered by startdate
      case_logs = retrieve_case_logs
      daily_run_number = get_next_run_number
      write_master_manifest(daily_run_number)
      write_export_data(case_logs)

      export = LogsExport.new(daily_run_number:)
      export.save!
      export
    end

    def is_omitted_field?(field_name)
      omitted_attrs = %w[ethnic_group]
      pattern_age = /age\d_known/
      field_name.starts_with?("details_known_") || pattern_age.match(field_name) || omitted_attrs.include?(field_name) ? true : false
    end

  private

    def get_next_run_number
      today = Time.zone.today
      last_daily_run_number = LogsExport.where(created_at: today.beginning_of_day..today.end_of_day).maximum(:daily_run_number)
      if last_daily_run_number.nil?
        1
      else
        last_daily_run_number + 1
      end
    end

    def write_master_manifest(daily_run_number)
      today = Time.zone.today
      increment_number = daily_run_number.to_s.rjust(4, "0")
      month = today.month.to_s.rjust(2, "0")
      day = today.day.to_s.rjust(2, "0")
      file_path = "Manifest_#{today.year}_#{month}_#{day}_#{increment_number}.csv"
      string_io = build_manifest_csv_io
      @storage_service.write_file(file_path, string_io)
    end

    def get_zip_naming(case_log, base_number, increment)
      collection_start = case_log.collection_start_year
      month = case_log.startdate.month
      quarter = QUARTERS[(month - 1) / 3]
      base_number_str = "f#{base_number.to_s.rjust(4, '0')}"
      increment_str = "inc#{increment.to_s.rjust(3, '0')}"
      "core_#{collection_start}_#{collection_start + 1}_#{quarter}_#{base_number_str}_#{increment_str}.zip"
    end

    def write_export_data(case_logs)
      zip_filenames = []
      case_logs.each do |case_log|
        zip_filename= get_zip_naming(case_log, 1, 1)
        unless zip_filenames.include?(zip_filename)
          zip_io = Zip::File.open_buffer(StringIO.new)
          zip_io.add("my_file", Tempfile.new)
          @storage_service.write_file(zip_filename, zip_io.write_buffer)
        end
      end

      string_io = build_export_xml_io(case_logs)
      file_path = "#{get_folder_name}/#{get_file_name}.xml"
      @storage_service.write_file(file_path, string_io)
    end

    def retrieve_case_logs
      CaseLog.all
    end

    def build_manifest_csv_io
      headers = ["zip-name", "date-time zipped folder generated", "zip-file-uri"]
      csv_string = CSV.generate do |csv|
        csv << headers
      end
      StringIO.new(csv_string)
    end

    def build_export_xml_io(case_logs)
      doc = Nokogiri::XML("<forms/>")

      case_logs.each do |case_log|
        form = doc.create_element("form")
        doc.at("forms") << form
        case_log.attributes.each do |key, _|
          if is_omitted_field?(key)
            next
          else
            value = case_log.read_attribute_before_type_cast(key)
            value += LOG_ID_OFFSET if key == "id"
            form << doc.create_element(key, value)
          end
        end
        form << doc.create_element("providertype", case_log.owning_organisation.read_attribute_before_type_cast(:provider_type))
      end
      doc.write_xml_to(StringIO.new, encoding: "UTF-8")
    end

    def get_folder_name
      "core_#{day_as_string}"
    end

    def get_file_name
      "dat_core_#{day_as_string}_#{increment_as_string}"
    end

    def day_as_string
      Time.current.strftime("%Y_%m_%d")
    end

    def increment_as_string(increment = 1)
      sprintf("%04d", increment)
    end
  end
end
