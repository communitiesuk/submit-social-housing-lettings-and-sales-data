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
      old_id = field_value(xml_doc, "meta", "document-id")
      record = CaseLog.find_by(old_id:)

      if record.present?
        tenant_code = string_or_nil(xml_doc, "_2bTenCode")
        if tenant_code.present? && record.tenant_code.blank?
          record.update!(tenant_code:)
        else
          @logger.info("Case Log #{record.id} has a value for tenant_code, skipping update")
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
