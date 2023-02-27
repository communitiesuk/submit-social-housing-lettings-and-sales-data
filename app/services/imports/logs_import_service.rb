module Imports
  class LogsImportService < ImportService
  private

    # Safe: A string that represents only an integer (or empty/nil)
    def safe_string_as_integer(xml_doc, attribute)
      str = field_value(xml_doc, "xmlns", attribute)
      Integer(str, exception: false)
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

    def find_organisation_id(xml_doc, id_field)
      old_visible_id = string_or_nil(xml_doc, id_field)
      organisation = Organisation.find_by(old_visible_id:)
      raise "Organisation not found with legacy ID #{old_visible_id}" if organisation.nil?

      organisation.id
    end

    def string_or_nil(xml_doc, attribute)
      str = field_value(xml_doc, "xmlns", attribute)
      str.presence
    end

    def ethnic_group(ethnic)
      case ethnic
      when 1, 2, 3, 18
        # White
        0
      when 4, 5, 6, 7
        # Mixed
        1
      when 8, 9, 10, 11, 15
        # Asian
        2
      when 12, 13, 14
        # Black
        3
      when 16, 19
        # Others
        4
      when 17
        # Refused
        17
      end
    end

    # Safe: A string that represents only a decimal (or empty/nil)
    def safe_string_as_decimal(xml_doc, attribute)
      str = string_or_nil(xml_doc, attribute)
      if str.nil?
        nil
      else
        BigDecimal(str, exception: false)
      end
    end

    def compose_postcode(xml_doc, outcode, incode)
      outcode_value = string_or_nil(xml_doc, outcode)
      incode_value = string_or_nil(xml_doc, incode)
      if outcode_value.nil? || incode_value.nil? || !"#{outcode_value} #{incode_value}".match(POSTCODE_REGEXP)
        nil
      else
        "#{outcode_value} #{incode_value}"
      end
    end

    def previous_postcode_known(xml_doc, previous_postcode, prevloc)
      previous_postcode_known = string_or_nil(xml_doc, "Q7UnknownPostcode")
      if previous_postcode_known == "If postcode not known tick" || (previous_postcode.nil? && prevloc.present?)
        1
      elsif previous_postcode.nil?
        nil
      else
        0
      end
    end

    def sex(xml_doc, index)
      sex = string_or_nil(xml_doc, "P#{index}Sex")
      case sex
      when "Male"
        "M"
      when "Female"
        "F"
      when "Other", "Non-binary"
        "X"
      when "Refused"
        "R"
      end
    end

    def relat(xml_doc, index)
      relat = string_or_nil(xml_doc, "P#{index}Rel")
      case relat
      when "Child"
        "C"
      when "Partner"
        "P"
      when "Other", "Non-binary"
        "X"
      when "Refused", "Buyer prefers not to say"
        "R"
      end
    end
  end
end
