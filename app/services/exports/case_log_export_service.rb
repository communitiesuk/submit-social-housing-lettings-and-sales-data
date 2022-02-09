# Temporary instructions for reference
# (to be updated on feedback and deleted when implemented)
#
# create manifest file (one per run), have to be daily even with no data
# manifest => Manifest_2022_01_30_0001(i).csv
# folder_name / timestamp / full_path
#
# folder => core_year_month_f0001 (use day for now)
# file => dat_core_year_month_f0001_0001(i).xml (increment matches manifest for a given day)
#
# [Manifest generation]
# iterate manifests for the day and determine next increment
# read previous manifest if present (read timestamp / reuse folder name)
# otherwise determine next folder for the month
# hold writing manifest until we checked for data
#
# [Retrieve case logs]
# Find all case logs updates from last run of the day (midnight if none)
# Write manifest
# Determine next increment for the folder (inc = 1 if none)
# Export retrieved case logs into XML file
#
# [Zipping mechanism left for later]

module Exports
  class CaseLogExportService
    def initialize(storage_service, logger = Rails.logger)
      @storage_service = storage_service
      @logger = logger
    end

    def export_case_logs
      case_logs = retrieve_case_logs
      string_io = build_export_string_io(case_logs)
      file_path = "#{get_folder_name}/#{get_file_name}.xml"
      @storage_service.write_file(file_path, string_io)
    end

  private

    def retrieve_case_logs
      params = { from: Time.current.beginning_of_day, to: Time.current, status: CaseLog.statuses[:completed] }
      CaseLog.where("updated_at >= :from and updated_at <= :to and status = :status", params)
    end

    def build_export_string_io(case_logs)
      doc = Nokogiri::XML("<forms/>")

      case_logs.each do |case_log|
        form = doc.create_element("form")
        doc.at("forms") << form
        case_log.attributes.each do |key, value|
          form << doc.create_element(key, value)
        end
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
