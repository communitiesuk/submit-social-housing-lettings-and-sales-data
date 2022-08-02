module Imports
  class CoreImportService < ImportService

    def start_import

    end

  private

    ARCHIVE_FOLDERS = {
      organisation: "institution",
      scheme: "mgmtgroups",
      scheme_location: "schemes",
      user: "user",
      data_protection_confirmation: "dataprotect",
      organisation_rent_periods: "rent-period",
      case_log: "logs"
    }.freeze


  end
end
