module Imports
  class CaseLogsFieldImportService < ImportService
    def update_field(field, folder)
      case field
      when "tenant_code"
        import_from(folder, :update_tenant_code)
      when "major_repairs"
        import_from(folder, :update_major_repairs)
      when "lettings_allocation"
        import_from(folder, :update_lettings_allocation)
      else
        raise "Updating #{field} is not supported by the field import service"
      end
    end

  private

    def update_lettings_allocation(xml_doc)
      old_id = field_value(xml_doc, "meta", "document-id")
      previous_status = field_value(xml_doc, "meta", "status")
      record = CaseLog.find_by(old_id:)

      if record.present? && previous_status.include?("submitted")
        cbl = unsafe_string_as_integer(xml_doc, "Q15CBL")
        chr = unsafe_string_as_integer(xml_doc, "Q15CHR")
        cap = unsafe_string_as_integer(xml_doc, "Q15CAP")
        if cbl == 2 && record.cbl == 1
          record.update!(cbl: 0)
          @logger.info("Case Log #{record.id}'s cbl value has been updated'")
        end
        if chr == 2 && record.chr == 1
          record.update!(chr: 0)
          @logger.info("Case Log #{record.id}'s chr value has been updated'")
        end
        if cap == 2 && record.cap == 1
          record.update!(cap: 0)
          @logger.info("Case Log #{record.id}'s cap value has been updated'")
        end
      else
        @logger.warn("Could not find record matching legacy ID #{old_id}")
      end
    end

    def update_major_repairs(xml_doc)
      old_id = field_value(xml_doc, "meta", "document-id")
      record = CaseLog.find_by(old_id:)

      if record.present?
        previous_status = field_value(xml_doc, "meta", "status")
        major_repairs_date = compose_date(xml_doc, "MRCDAY", "MRCMONTH", "MRCYEAR")
        major_repairs = if major_repairs_date.present? && previous_status.include?("submitted")
                          1
                        elsif previous_status.include?("submitted")
                          0
                        end
        if major_repairs.present? && record.majorrepairs.nil? && record.status != "completed"
          record.update!(mrcdate: major_repairs_date, majorrepairs: major_repairs)
          @logger.info("Case Log #{record.id}'s major repair value has been updated'")
        elsif record.majorrepairs.present?
          @logger.info("Case Log #{record.id} has a value for major repairs, skipping update")
        end
      else
        @logger.warn("Could not find record matching legacy ID #{old_id}")
      end
    end

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

    def compose_date(xml_doc, day_str, month_str, year_str)
      day = Integer(field_value(xml_doc, "xmlns", day_str), exception: false)
      month = Integer(field_value(xml_doc, "xmlns", month_str), exception: false)
      year = Integer(field_value(xml_doc, "xmlns", year_str), exception: false)
      if day.nil? || month.nil? || year.nil?
        nil
      else
        Time.zone.local(year, month, day)
      end
    end

    def string_or_nil(xml_doc, attribute)
      str = field_value(xml_doc, "xmlns", attribute)
      str.presence
    end

    # Unsafe: A string that has more than just the integer value
    def unsafe_string_as_integer(xml_doc, attribute)
      str = string_or_nil(xml_doc, attribute)
      if str.nil?
        nil
      else
        str.to_i
      end
    end
  end
end
