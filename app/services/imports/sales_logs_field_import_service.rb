module Imports
  class SalesLogsFieldImportService < LogsImportService
    def update_field(field, folder)
      case field
      when "creation_method"
        import_from(folder, :update_creation_method)
      when "owning_organisation_id"
        import_from(folder, :update_owning_organisation_id)
      else
        raise "Updating #{field} is not supported by the field import service"
      end
    end

  private

    def update_creation_method(xml_doc)
      return if meta_field_value(xml_doc, "form-name").include?("Lettings")

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

    def update_owning_organisation_id(xml_doc)
      return if meta_field_value(xml_doc, "form-name").include?("Lettings")

      old_id = meta_field_value(xml_doc, "document-id")
      record = SalesLog.find_by(old_id:)

      if record.present?
        if record.owning_organisation_id.present?
          @logger.info("sales log #{record.id} has a value for owning_organisation_id, skipping update")
        else
          old_owning_organisation_id = safe_string_as_integer(xml_doc, "OWNINGORGID")
          new_owning_organisation_id = Organisation.find_by(old_visible_id: old_owning_organisation_id).id
          record.update!(owning_organisation_id: new_owning_organisation_id)
          @logger.info("sales log #{record.id}'s owning_organisation_id value has been set to #{new_owning_organisation_id}")
        end
      else
        @logger.warn("sales log with old id #{old_id} not found")
      end
    end
  end
end
