module Exports
  class CaseLogExportService
    def initialize(storage_service, logger = Rails.logger)
      @storage_service = storage_service
      @logger = logger
    end

    def export_case_logs
      case_logs = retrieve_case_logs
      export = save_export_run
      write_master_manifest(export)
      write_export_data(case_logs)
    end

    def is_omitted_field?(field_name)
      omitted_attrs = %w[ethnic_group]
      pattern_age = /age\d_known/
      field_name.starts_with?("details_known_") || pattern_age.match(field_name) || omitted_attrs.include?(field_name) ? true : false
    end

    LOG_ID_OFFSET = 300_000_000_000

  private

    def save_export_run
      today = Time.zone.today
      last_daily_run_number = LogsExport.where(created_at: today.beginning_of_day..today.end_of_day).maximum(:daily_run_number)

      export = LogsExport.new
      if last_daily_run_number.nil?
        export.daily_run_number = 1
      else
        export.daily_run_number = last_daily_run_number + 1
      end
      export.save!
      export
    end

    def write_master_manifest(export)
      today = Time.zone.today
      increment_number = export.daily_run_number.to_s.rjust(4, "0")
      month = today.month.to_s.rjust(2, "0")
      day = today.day.to_s.rjust(2, "0")
      file_path = "Manifest_#{today.year}-#{month}-#{day}_#{increment_number}.csv"
      string_io = build_manifest_csv_io
      @storage_service.write_file(file_path, string_io)
    end

    def write_export_data(case_logs)
      string_io = build_export_xml_io(case_logs)
      file_path = "#{get_folder_name}/#{get_file_name}.xml"
      @storage_service.write_file(file_path, string_io)
    end

    def retrieve_case_logs
      # All logs from previous (successful) start time to current start time (not current) [ignore status]
      params = { from: Time.current.beginning_of_day, to: Time.current, status: CaseLog.statuses[:completed] }
      CaseLog.where("updated_at >= :from and updated_at <= :to and status = :status", params)
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
