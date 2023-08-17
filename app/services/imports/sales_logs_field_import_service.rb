module Imports
  class SalesLogsFieldImportService < LogsImportService
    def update_field(field, folder)
      case field
      when "creation_method"
        import_from(folder, :update_creation_method)
      when "owning_organisation_id"
        import_from(folder, :update_owning_organisation_id)
      when "old_form_id"
        import_from(folder, :update_old_form_id)
      else
        raise "Updating #{field} is not supported by the field import service"
      end
    end

  private

    def update_creation_method(xml_doc)
      return unless meta_field_value(xml_doc, "form-name").include?("Sales")

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
      return unless meta_field_value(xml_doc, "form-name").include?("Sales")

      old_id = meta_field_value(xml_doc, "document-id")
      record = SalesLog.find_by(old_id:)

      if record.present?
        if record.owning_organisation_id.present?
          @logger.info("sales log #{record.id} has a value for owning_organisation_id, skipping update")
        else
          owning_organisation_id = find_organisation_id(xml_doc, "OWNINGORGID")
          record.update!(owning_organisation_id:)
          @logger.info("sales log #{record.id}'s owning_organisation_id value has been set to #{owning_organisation_id}")
        end
      else
        @logger.warn("sales log with old id #{old_id} not found")
      end
    end

    def update_old_form_id(xml_doc)
      return unless meta_field_value(xml_doc, "form-name").include?("Sales")

      old_id = meta_field_value(xml_doc, "document-id")
      record = SalesLog.find_by(old_id:)

      if record.present?
        if record.old_form_id.present?
          @logger.info("sales log #{record.id} has a value for old_form_id, skipping update")
        else
          old_form_id = safe_string_as_integer(xml_doc, "Form")
          record.update!(old_form_id:)
          @logger.info("sales log #{record.id}'s old_form_id value has been set to #{old_form_id}")
        end
      else
        @logger.warn("sales log with old id #{old_id} not found")
      end
    end
  end
end
