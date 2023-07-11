module Imports
  class SalesLogsFieldImportService < LogsImportService
    def update_field(field, folder)
      case field
      when "creation_method"
        import_from(folder, :update_creation_method)
      else
        raise "Updating #{field} is not supported by the field import service"
      end
    end

  private

    def update_creation_method(xml_doc)
      old_id = meta_field_value(xml_doc, "document-id")
      log = SalesLog.find_by(old_id:)

      return @logger.warn "sales log with old id #{old_id} not found" unless log

      upload_id = meta_field_value(xml_doc, "upload-id")

      if upload_id.nil?
        @logger.info "sales log with old id #{old_id} entered manually, no need for update"
      elsif log.creation_method_bulk_upload?
        @logger.info "sales log #{log.id} creation method already set to bulk upload, no need for update"
      else
        log.creation_method_bulk_upload!
        @logger.info "sales log #{log.id} creation method set to bulk upload"
      end
    end
  end
end
