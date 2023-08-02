module Imports
  class ImportReportService
    def initialize(storage_service, old_organisation_ids, logger = Rails.logger)
      @storage_service = storage_service
      @logger = logger
      @old_organisation_ids = old_organisation_ids
    end

    BYTE_ORDER_MARK = "\uFEFF".freeze # Required to ensure Excel always reads CSV as UTF-8

    def create_report(report_directory)
      write_missing_data_coordinators_report(report_directory)
    end

    def write_missing_data_coordinators_report(report_directory)
      csv_string = "Organisation ID,Old Organisation ID,Organisation Name\n"
      @old_organisation_ids.each do |old_organisation_id|
        organisation = Organisation.find_by(old_visible_id: old_organisation_id)
        if organisation.users.none?(&:data_coordinator?)
          csv_string += "#{organisation.id},#{old_organisation_id},#{organisation.name}\n"
        end
      end

      @storage_service.write_file("#{report_directory}/organisations_without_data_coordinators.csv", BYTE_ORDER_MARK + csv_string)
    end
  end
end
