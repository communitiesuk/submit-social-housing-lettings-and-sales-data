module Imports
  class CaseLogsImportService < ImportService
    def create_logs(folder)
      import_from(folder, :create_log)
    end

  private

    GN_SH = {
      general_needs: 1,
      supported_housing: 2,
    }.freeze

    SR_AR_IR = {
      social_rent: 1,
      affordable_rent: 2,
      intermediate_rent: 3,
    }.freeze

    # For providertype, values are reversed!!!
    PRP_LA = {
      private_registered_provider: 1,
      local_authority: 2,
    }.freeze

    IRPRODUCT = {
      rent_to_buy: 1,
      london_living_rent: 2,
      other_intermediate_rent_product: 3,
    }.freeze

    # These must match our form
    RENT_TYPE = {
      social_rent: 0,
      affordable_rent: 1,
      london_affordable_rent: 2,
      rent_to_buy: 3,
      london_living_rent: 4,
      other_intermediate_rent_product: 5,
    }.freeze

    # Order matters since we derive from previous values (uses attributes)
    def create_log(xml_doc)
      attributes = {}

      # Required fields for status complete or logic to work
      attributes["startdate"] = start_date(xml_doc)
      attributes["owning_organisation_id"] = find_organisation_id(xml_doc, "OWNINGORGID")
      attributes["managing_organisation_id"] = find_organisation_id(xml_doc, "MANINGORGID")
      attributes["previous_postcode_known"] = previous_postcode_known(xml_doc)
      attributes["ppostcode_full"] = previous_postcode(xml_doc, attributes)
      attributes["needstype"] = needs_type(xml_doc)
      attributes["lar"] = london_affordable_rent(xml_doc)
      attributes["irproduct"] = unsafe_string_as_integer(xml_doc, "IRPRODUCT")
      attributes["irproduct_other"] = field_value(xml_doc, "xmlns", "IRPRODUCTOTHER")
      attributes["rent_type"] = rent_type(xml_doc, attributes)
      attributes["rsnvac"] = unsafe_string_as_integer(xml_doc, "Q27")
      attributes["renewal"] = renewal(attributes)
      (1..8).each do |index|
        attributes["age#{index}"] = age(xml_doc, index)
        attributes["sex#{index}"] = sex(xml_doc, index)
        attributes["ecstat#{index}"] = unsafe_string_as_integer(xml_doc, "P#{index}Eco")
      end
      # attributes["hhmemb"] =

      # Not specific to our form but required for CDS and can't be inferred
      # attributes["form"] = Integer(field_value(xml_doc, "xmlns", "FORM"))
      # attributes["lettype"] = let_type(xml_doc, attributes)

      case_log = CaseLog.new(attributes)
      case_log.save!

      # pp attributes
      # pp case_log.status
      # pp case_log.send(:mandatory_fields)
    end

    def start_date(xml_doc)
      day = Integer(field_value(xml_doc, "xmlns", "DAY"))
      month = Integer(field_value(xml_doc, "xmlns", "MONTH"))
      year = Integer(field_value(xml_doc, "xmlns", "YEAR"))
      Date.new(year, month, day)
    end

    def get_form_name_component(xml_doc, index)
      form_name = field_value(xml_doc, "meta", "form-name")
      form_type_components = form_name.split("-")
      form_type_components[index]
    end

    def needs_type(xml_doc)
      gn_sh = get_form_name_component(xml_doc, -1)
      case gn_sh
      when "GN"
        GN_SH[:general_needs]
      when "SH"
        GN_SH[:supported_housing]
      else
        raise "Unknown needstype value: #{gn_sh}"
      end
    end

    # This does not match renttype (CDS) which is derived by case logs logic
    def rent_type(xml_doc, attributes)
      sr_ar_ir = get_form_name_component(xml_doc, -2)

      case sr_ar_ir
      when "SR"
        RENT_TYPE[:social_rent]
      when "AR"
        if attributes["lar"] == 1
          RENT_TYPE[:london_affordable_rent]
        else
          RENT_TYPE[:affordable_rent]
        end
      when "IR"
        if attributes["irproduct"] == IRPRODUCT[:rent_to_buy]
          RENT_TYPE[:rent_to_buy]
        elsif attributes["irproduct"] == IRPRODUCT[:london_living_rent]
          RENT_TYPE[:london_living_rent]
        elsif attributes["irproduct"] == IRPRODUCT[:other_intermediate_rent_product]
          RENT_TYPE[:other_intermediate_rent_product]
        end
      end
    end

    # def let_type(xml_doc, attributes)
    #   # "1 Private Registered Provider" or "2 Local Authority"
    #   # We do not store providertype since it comes from the organisation import
    #   landlord = field_value(xml_doc, "xmlns", "Landlord").to_i
    #
    #   if attributes["renttype"] == SR_AR_IR[:social_rent] &&
    #       attributes["needstype"] == GN_SH[:general_needs] &&
    #       landlord == PRP_LA[:private_registered_provider]
    #     1
    #   elsif attributes["renttype"] == SR_AR_IR[:social_rent] &&
    #       attributes["needstype"] == GN_SH[:supported_housing] &&
    #       landlord == PRP_LA[:private_registered_provider]
    #     2
    #   elsif attributes["renttype"] == SR_AR_IR[:social_rent] &&
    #       attributes["needstype"] == GN_SH[:general_needs] &&
    #       landlord == PRP_LA[:local_authority]
    #     3
    #   elsif attributes["renttype"] == SR_AR_IR[:social_rent] &&
    #       attributes["needstype"] == GN_SH[:supported_housing] &&
    #       landlord == PRP_LA[:local_authority]
    #     4
    #   elsif attributes["renttype"] == SR_AR_IR[:affordable_rent] &&
    #       attributes["needstype"] == GN_SH[:general_needs] &&
    #       landlord == PRP_LA[:private_registered_provider]
    #     5
    #   elsif attributes["renttype"] == SR_AR_IR[:affordable_rent] &&
    #       attributes["needstype"] == GN_SH[:supported_housing] &&
    #       landlord == PRP_LA[:private_registered_provider]
    #     6
    #   elsif attributes["renttype"] == SR_AR_IR[:affordable_rent] &&
    #       attributes["needstype"] == GN_SH[:general_needs] &&
    #       landlord == PRP_LA[:local_authority]
    #     7
    #   elsif attributes["renttype"] == SR_AR_IR[:affordable_rent] &&
    #       attributes["needstype"] == GN_SH[:supported_housing] &&
    #       landlord == PRP_LA[:local_authority]
    #     8
    #   elsif attributes["renttype"] == SR_AR_IR[:intermediate_rent] &&
    #       attributes["needstype"] == GN_SH[:general_needs] &&
    #       landlord == PRP_LA[:private_registered_provider]
    #     9
    #   elsif attributes["renttype"] == SR_AR_IR[:intermediate_rent] &&
    #       attributes["needstype"] == GN_SH[:supported_housing] &&
    #       landlord == PRP_LA[:private_registered_provider]
    #     10
    #   elsif attributes["renttype"] == SR_AR_IR[:intermediate_rent] &&
    #       attributes["needstype"] == GN_SH[:general_needs] &&
    #       landlord == PRP_LA[:local_authority]
    #     11
    #   elsif attributes["renttype"] == SR_AR_IR[:intermediate_rent] &&
    #       attributes["needstype"] == GN_SH[:supported_housing] &&
    #       landlord == PRP_LA[:local_authority]
    #     12
    #   else
    #     raise "Could not infer rent type with rentype:#{attributes['renttype']} / needstype:#{attributes['needstype']} / landlord:#{landlord}"
    #   end
    # end

    def find_organisation_id(xml_doc, field)
      old_visible_id = field_value(xml_doc, "xmlns", field).to_i
      landlord = field_value(xml_doc, "xmlns", "Landlord").to_i

      organisation = Organisation.find_by(old_visible_id:)
      # Quick hack: should be removed when all organisations are imported
      # Will fail in the future if the organisation is missing
      if organisation.nil?
        organisation = Organisation.new
        organisation.old_visible_id = old_visible_id
        organisation.provider_type = if landlord == 2
                                       1
                                     else
                                       2
                                     end
        organisation.save!
      end
      organisation.id
    end

    def age(xml_doc, index)
      Integer(field_value(xml_doc, "xmlns", "P#{index}Age"), exception: false)
    end

    def sex(xml_doc, index)
      sex = field_value(xml_doc, "xmlns", "P#{index}Sex")
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

    def previous_postcode_known(xml_doc)
      previous_postcode_known = field_value(xml_doc, "xmlns", "Q12bnot")
      if previous_postcode_known == "Temporary or Unknown"
        0
      else
        1
      end
    end

    def previous_postcode(xml_doc, attributes)
      previous_postcode_known = attributes["previous_postcode_known"]
      if previous_postcode_known.zero?
        nil
      else
        outcode = field_value(xml_doc, "xmlns", "PPOSTC1")
        incode = field_value(xml_doc, "xmlns", "PPOSTC2")
        "#{outcode} #{incode}"
      end
    end

    def london_affordable_rent(xml_doc)
      lar = unsafe_string_as_integer(xml_doc, "LAR")
      if lar == 1
        1
      else
        # We default to No for any other values (nil, not known)
        2
      end
    end

    def renewal(attributes)
      #  Relet – renewal of fixed-term tenancy
      if attributes["rsnvac"] == 14
        1
      else
        0
      end
    end

    # Safe: A string that represents only an integer (or empty/nil)
    def safe_string_as_integer(xml_doc, attribute)
      str = field_value(xml_doc, "xmlns", attribute)
      Integer(str, exception: false)
    end

    # Unsafe: A string that has more than just the integer value
    def unsafe_string_as_integer(xml_doc, attribute)
      str = field_value(xml_doc, "xmlns", attribute)
      if str.blank?
        nil
      else
        str.to_i
      end
    end
  end
end
