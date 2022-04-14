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

    def create_log(xml_doc)
      attributes = {}

      # Required fields for status complete or logic to work
      # Note: order matters when we derive from previous values (attributes parameter)
      attributes["startdate"] = compose_date(xml_doc, "DAY", "MONTH", "YEAR")
      attributes["owning_organisation_id"] = find_organisation_id(xml_doc, "OWNINGORGID")
      attributes["managing_organisation_id"] = find_organisation_id(xml_doc, "MANINGORGID")
      attributes["startertenancy"] = unsafe_string_as_integer(xml_doc, "_2a")
      attributes["tenancy"] = unsafe_string_as_integer(xml_doc, "Q2b")
      attributes["tenancyother"] = string_or_nil(xml_doc, "Q2ba")
      attributes["tenancylength"] = safe_string_as_integer(xml_doc, "_2cYears")
      attributes["needstype"] = needs_type(xml_doc)
      attributes["lar"] = london_affordable_rent(xml_doc)
      attributes["irproduct"] = unsafe_string_as_integer(xml_doc, "IRPRODUCT")
      attributes["irproduct_other"] = string_or_nil(xml_doc, "IRPRODUCTOTHER")
      attributes["rent_type"] = rent_type(xml_doc, attributes["lar"], attributes["irproduct"])
      attributes["hhmemb"] = safe_string_as_integer(xml_doc, "HHMEMB")
      (1..8).each do |index|
        attributes["age#{index}"] = safe_string_as_integer(xml_doc, "P#{index}Age")
        attributes["age#{index}_known"] = age_known(xml_doc, index, attributes["hhmemb"])
        attributes["sex#{index}"] = sex(xml_doc, index)
        attributes["ecstat#{index}"] = unsafe_string_as_integer(xml_doc, "P#{index}Eco")
      end
      (2..8).each do |index|
        attributes["relat#{index}"] = relat(xml_doc, index)
      end
      attributes["ethnic"] = unsafe_string_as_integer(xml_doc, "P1Eth")
      attributes["ethnic_group"] = ethnic_group(attributes["ethnic"])
      attributes["national"] = unsafe_string_as_integer(xml_doc, "P1Nat")
      attributes["preg_occ"] = unsafe_string_as_integer(xml_doc, "Preg")

      attributes["armedforces"] = unsafe_string_as_integer(xml_doc, "ArmedF")
      attributes["leftreg"] = unsafe_string_as_integer(xml_doc, "LeftAF")
      attributes["reservist"] = unsafe_string_as_integer(xml_doc, "Inj")

      attributes["hb"] = unsafe_string_as_integer(xml_doc, "Q6Ben")
      attributes["benefits"] = unsafe_string_as_integer(xml_doc, "Q7Ben")
      attributes["earnings"] = safe_string_as_decimal(xml_doc, "Q8Money")
      attributes["net_income_known"] = net_income_known(xml_doc, attributes["earnings"])
      attributes["incfreq"] = unsafe_string_as_integer(xml_doc, "Q8a")

      attributes["reason"] = unsafe_string_as_integer(xml_doc, "Q9a")
      attributes["reasonother"] = string_or_nil(xml_doc, "Q9aa")
      attributes["underoccupation_benefitcap"] = unsafe_string_as_integer(xml_doc, "_9b")
      %w[a b c f g h].each do |letter|
        attributes["housingneeds_#{letter}"] = housing_needs(xml_doc, letter)
      end

      attributes["illness"] = unsafe_string_as_integer(xml_doc, "Q10ia")
      (1..10).each do |index|
        attributes["illness_type_#{index}"] = illness_type(xml_doc, index)
      end

      attributes["prevten"] = unsafe_string_as_integer(xml_doc, "Q11")
      attributes["prevloc"] = string_or_nil(xml_doc, "Q12aONS")
      attributes["previous_postcode_known"] = previous_postcode_known(xml_doc)
      attributes["ppostcode_full"] = compose_postcode(xml_doc, "PPOSTC1", "PPOSTC2")
      attributes["layear"] = unsafe_string_as_integer(xml_doc, "Q12c")
      attributes["waityear"] = unsafe_string_as_integer(xml_doc, "Q12d")
      attributes["homeless"] = unsafe_string_as_integer(xml_doc, "Q13")

      attributes["reasonpref"] = unsafe_string_as_integer(xml_doc, "Q14a")
      attributes["rp_homeless"] = unsafe_string_as_integer(xml_doc, "Q14b1")
      attributes["rp_insan_unsat"] = unsafe_string_as_integer(xml_doc, "Q14b2")
      attributes["rp_medwel"] = unsafe_string_as_integer(xml_doc, "Q14b3")
      attributes["rp_hardship"] = unsafe_string_as_integer(xml_doc, "Q14b4")
      attributes["rp_dontknow"] = unsafe_string_as_integer(xml_doc, "Q14b5")

      attributes["cbl"] = unsafe_string_as_integer(xml_doc, "Q15CBL")
      attributes["chr"] = unsafe_string_as_integer(xml_doc, "Q15CHR")
      attributes["cap"] = unsafe_string_as_integer(xml_doc, "Q15CAP")

      attributes["referral"] = unsafe_string_as_integer(xml_doc, "Q16")
      attributes["period"] = unsafe_string_as_integer(xml_doc, "Q17")

      attributes["brent"] = safe_string_as_decimal(xml_doc, "Q18ai")
      attributes["scharge"] = safe_string_as_decimal(xml_doc, "Q18aii")
      attributes["pscharge"] = safe_string_as_decimal(xml_doc, "Q18aiii")
      attributes["supcharg"] = safe_string_as_decimal(xml_doc, "Q18aiv")
      attributes["tcharge"] = safe_string_as_decimal(xml_doc, "Q18av")

      attributes["hbrentshortfall"] = unsafe_string_as_integer(xml_doc, "Q18d")

      attributes["voiddate"] = compose_date(xml_doc, "VDAY", "VMONTH", "VYEAR")
      attributes["mrcdate"] = compose_date(xml_doc, "MRCDAY", "MRCMONTH", "MRCYEAR")

      attributes["offered"] = safe_string_as_integer(xml_doc, "Q20")
      attributes["propcode"] = string_or_nil(xml_doc, "Q21a")
      attributes["beds"] = safe_string_as_integer(xml_doc, "Q22")
      attributes["unittype_gn"] = unsafe_string_as_integer(xml_doc, "Q23")
      attributes["builtype"] = unsafe_string_as_integer(xml_doc, "Q24")
      attributes["wchair"] = unsafe_string_as_integer(xml_doc, "Q25")
      attributes["unitletas"] = unsafe_string_as_integer(xml_doc, "Q26")
      attributes["rsnvac"] = unsafe_string_as_integer(xml_doc, "Q27")
      attributes["renewal"] = renewal(attributes["rsnvac"])

      attributes["la"] = string_or_nil(xml_doc, "Q28ONS")
      attributes["postcode_full"] = compose_postcode(xml_doc, "POSTCODE", "POSTCOD2")
      attributes["postcode_known"] = attributes["postcode_full"].nil? ? 0 : 1

      # Not specific to our form but required for CDS and can't be inferred
      attributes["old_form_id"] = Integer(field_value(xml_doc, "xmlns", "FORM"))

      # Specific to us
      attributes["previous_la_known"] = 1 # Defaulting to Yes (Required)
      attributes["la_known"] = 1 # Defaulting to Yes (Required)
      attributes["created_at"] = Date.parse(field_value(xml_doc, "meta", "created-date"))
      attributes["updated_at"] = Date.parse(field_value(xml_doc, "meta", "modified-date"))
      attributes

      # Pending validation with new form
      # case_log = CaseLog.new(attributes)
      # case_log.save!
    end

    # Safe: A string that represents only an integer (or empty/nil)
    def safe_string_as_integer(xml_doc, attribute)
      str = field_value(xml_doc, "xmlns", attribute)
      Integer(str, exception: false)
    end

    # Safe: A string that represents only a decimal (or empty/nil)
    def safe_string_as_decimal(xml_doc, attribute)
      str = field_value(xml_doc, "xmlns", attribute)
      BigDecimal(str, exception: false)
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

    def compose_date(xml_doc, day_str, month_str, year_str)
      day = Integer(field_value(xml_doc, "xmlns", day_str), exception: false)
      month = Integer(field_value(xml_doc, "xmlns", month_str), exception: false)
      year = Integer(field_value(xml_doc, "xmlns", year_str), exception: false)
      if day.nil? || month.nil? || year.nil?
        nil
      else
        Date.new(year, month, day)
      end
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

    # This does not match renttype (CDS) which is derived by case log logic
    def rent_type(xml_doc, lar, irproduct)
      sr_ar_ir = get_form_name_component(xml_doc, -2)

      case sr_ar_ir
      when "SR"
        RENT_TYPE[:social_rent]
      when "AR"
        if lar == 1
          RENT_TYPE[:london_affordable_rent]
        else
          RENT_TYPE[:affordable_rent]
        end
      when "IR"
        if irproduct == IRPRODUCT[:rent_to_buy]
          RENT_TYPE[:rent_to_buy]
        elsif irproduct == IRPRODUCT[:london_living_rent]
          RENT_TYPE[:london_living_rent]
        elsif irproduct == IRPRODUCT[:other_intermediate_rent_product]
          RENT_TYPE[:other_intermediate_rent_product]
        end
      else
        raise "Could not infer rent type with '#{sr_ar_ir}'"
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

    def relat(xml_doc, index)
      relat = field_value(xml_doc, "xmlns", "P#{index}Rel")
      case relat
      when "Child"
        "C"
      when "Partner"
        "P"
      when "Other", "Non-binary"
        "X"
      when "Refused"
        "R"
      end
    end

    def age_known(xml_doc, index, hhmemb)
      return nil if index > hhmemb

      age_refused = field_value(xml_doc, "xmlns", "P#{index}AR")
      if age_refused == "AGE_REFUSED"
        1 # No
      else
        0 # Yes
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

    def compose_postcode(xml_doc, outcode, incode)
      outcode_value = field_value(xml_doc, "xmlns", outcode)
      incode_value = field_value(xml_doc, "xmlns", incode)
      if outcode_value.blank? || incode_value.blank?
        nil
      else
        "#{outcode_value} #{incode_value}"
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

    def renewal(rsnvac)
      #  Relet – renewal of fixed-term tenancy
      if rsnvac == 14
        1
      else
        0
      end
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
        5
      end
    end

    # Letters should be lowercase to match case
    def housing_needs(xml_doc, letter)
      housing_need = field_value(xml_doc, "xmlns", "Q10-#{letter}")
      if housing_need == "Yes"
        1
      else
        0
      end
    end

    def net_income_known(xml_doc, earnings)
      incref = field_value(xml_doc, "xmlns", "Q8Refused")
      if incref == "Refused"
        # Tenant prefers not to say
        2
      elsif earnings.nil?
        # No
        1
      else
        # Yes
        0
      end
    end

    def illness_type(xml_doc, index)
      illness_type = string_or_nil(xml_doc, "Q10ib-#{index}")
      if illness_type == "Yes"
        1
      else
        0
      end
    end
  end
end
