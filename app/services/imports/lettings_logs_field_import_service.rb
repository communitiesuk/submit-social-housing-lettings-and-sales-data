module Imports
  class LettingsLogsFieldImportService < LogsImportService
    def update_field(field, folder)
      case field
      when "tenancycode"
        import_from(folder, :update_tenant_code)
      when "major_repairs"
        import_from(folder, :update_major_repairs)
      when "lettings_allocation"
        import_from(folder, :update_lettings_allocation)
      when "offered"
        import_from(folder, :update_offered)
      when "creation_method"
        import_from(folder, :update_creation_method)
      else
        raise "Updating #{field} is not supported by the field import service"
      end
    end

  private

    def update_offered(xml_doc)
      return if meta_field_value(xml_doc, "form-name").include?("Sales")

      old_id = meta_field_value(xml_doc, "document-id")
      record = LettingsLog.find_by(old_id:)

      if record.present?
        if record.offered.present?
          @logger.info("lettings log #{record.id} has a value for offered, skipping update")
        else
          offered = safe_string_as_integer(xml_doc, "Q20")
          record.update!(offered:)
          @logger.info("lettings log #{record.id}'s offered value has been set to #{offered}")
        end
      else
        @logger.warn("lettings log with old id #{old_id} not found")
      end
    end

    def update_creation_method(xml_doc)
      old_id = meta_field_value(xml_doc, "document-id")
      log = LettingsLog.find_by(old_id:)

      return @logger.warn "lettings log with old id #{old_id} not found" unless log

      upload_id = meta_field_value(xml_doc, "upload-id")

      if upload_id.nil?
        @logger.info "lettings log with old id #{old_id} entered manually, no need for update"
      elsif log.creation_method_bulk_upload?
        @logger.info "lettings log #{log.id} creation method already set to bulk upload, no need for update"
      else
        log.creation_method_bulk_upload!
        @logger.info "lettings log #{log.id} creation method set to bulk upload"
      end
    end

    def update_lettings_allocation(xml_doc)
      return if meta_field_value(xml_doc, "form-name").include?("Sales")

      old_id = meta_field_value(xml_doc, "document-id")
      previous_status = meta_field_value(xml_doc, "status")
      record = LettingsLog.find_by(old_id:)

      if record.present? && previous_status.include?("submitted")
        cbl = unsafe_string_as_integer(xml_doc, "Q15CBL")
        chr = unsafe_string_as_integer(xml_doc, "Q15CHR")
        cap = unsafe_string_as_integer(xml_doc, "Q15CAP")
        if cbl == 2 && record.cbl == 1
          record.update!(cbl: 0)
          @logger.info("lettings log #{record.id}'s cbl value has been updated'")
        end
        if chr == 2 && record.chr == 1
          record.update!(chr: 0)
          @logger.info("lettings log #{record.id}'s chr value has been updated'")
        end
        if cap == 2 && record.cap == 1
          record.update!(cap: 0)
          @logger.info("lettings log #{record.id}'s cap value has been updated'")
        end
        if cbl == 2 && chr == 2 && cap == 2 && record.letting_allocation_unknown.nil?
          record.update!(letting_allocation_unknown: 1)
          @logger.info("lettings log #{record.id}'s letting_allocation_unknown value has been updated'")
        end
      else
        @logger.warn("Could not find record matching legacy ID #{old_id}")
      end
    end

    def update_major_repairs(xml_doc)
      return if meta_field_value(xml_doc, "form-name").include?("Sales")

      old_id = meta_field_value(xml_doc, "document-id")
      record = LettingsLog.find_by(old_id:)

      if record.present?
        previous_status = meta_field_value(xml_doc, "status")
        major_repairs_date = compose_date(xml_doc, "MRCDAY", "MRCMONTH", "MRCYEAR")
        major_repairs = if major_repairs_date.present? && previous_status.include?("submitted")
                          1
                        elsif previous_status.include?("submitted")
                          0
                        end
        if major_repairs.present? && record.majorrepairs.nil? && record.status != "completed"
          record.update!(mrcdate: major_repairs_date, majorrepairs: major_repairs)
          @logger.info("lettings log #{record.id}'s major repair value has been updated'")
        elsif record.majorrepairs.present?
          @logger.info("lettings log #{record.id} has a value for major repairs, skipping update")
        end
      else
        @logger.warn("Could not find record matching legacy ID #{old_id}")
      end
    end

    def update_tenant_code(xml_doc)
      return if meta_field_value(xml_doc, "form-name").include?("Sales")

      old_id = meta_field_value(xml_doc, "document-id")
      record = LettingsLog.find_by(old_id:)

      if record.present?
        tenant_code = string_or_nil(xml_doc, "_2bTenCode")
        if tenant_code.present? && record.tenancycode.blank?
          record.update!(tenancycode: tenant_code)
        else
          @logger.info("lettings log #{record.id} has a value for tenancycode, skipping update")
        end
      else
        @logger.warn("Could not find record matching legacy ID #{old_id}")
      end
    end
  end
end
