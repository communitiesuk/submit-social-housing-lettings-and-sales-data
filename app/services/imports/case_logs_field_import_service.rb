module Imports
  class CaseLogsFieldImportService < ImportService
    def update_field(field, folder)
      case field
      when "tenant_code"
        import_from(folder, :update_tenant_code)
      else
        raise "Updating #{field} is not supported by the field import service"
      end
    end

  private

    def update_tenant_code(xml_doc)
      update_string_value(xml_doc, "_2bTenCode", "tenant_code")
    end

    def update_string_value(xml_doc, src_field, dest_field)
      old_id = field_value(xml_doc, "meta", "document-id")
      record = CaseLog.find_by(old_id:)

      if record.present?
        tenant_code = string_or_nil(xml_doc, src_field)
        current_value = record.read_attribute(dest_field)
        if tenant_code.present? && current_value.blank?
          record.update_column(dest_field, tenant_code)
        else
          @logger.info("Case Log #{record.id} has a value for #{dest_field}, skipping update")
        end
      else
        @logger.warn("Could not find record matching legacy ID #{old_id}")
      end
    end

    def string_or_nil(xml_doc, attribute)
      str = field_value(xml_doc, "xmlns", attribute)
      str.presence
    end
  end
end
