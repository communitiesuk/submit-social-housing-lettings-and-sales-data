module Imports
  class CaseLogsImportService < ImportService
    def initialize(storage_service, logger = Rails.logger)
      @logs_with_discrepancies = Set.new
      @logs_overridden = Set.new
      super
    end

    def create_logs(folder)
      import_from(folder, :create_log)
      if @logs_with_discrepancies.count.positive?
        @logger.warn("The following case logs had status discrepancies: [#{@logs_with_discrepancies.join(', ')}]")
      end
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

      previous_status = field_value(xml_doc, "meta", "status")

      # Required fields for status complete or logic to work
      # Note: order matters when we derive from previous values (attributes parameter)
      attributes["startdate"] = compose_date(xml_doc, "DAY", "MONTH", "YEAR")
      attributes["owning_organisation_id"] = find_organisation_id(xml_doc, "OWNINGORGID")
      attributes["managing_organisation_id"] = find_organisation_id(xml_doc, "MANINGORGID")
      attributes["joint"] = unsafe_string_as_integer(xml_doc, "joint")
      attributes["startertenancy"] = unsafe_string_as_integer(xml_doc, "_2a")
      attributes["tenancy"] = unsafe_string_as_integer(xml_doc, "Q2b")
      attributes["tenant_code"] = string_or_nil(xml_doc, "_2bTenCode")
      attributes["tenancyother"] = string_or_nil(xml_doc, "Q2ba")
      attributes["tenancylength"] = safe_string_as_integer(xml_doc, "_2cYears")
      attributes["needstype"] = needs_type(xml_doc)
      attributes["lar"] = london_affordable_rent(xml_doc)
      attributes["irproduct"] = unsafe_string_as_integer(xml_doc, "IRProduct")
      attributes["irproduct_other"] = string_or_nil(xml_doc, "IRProductOther")
      attributes["rent_type"] = rent_type(xml_doc, attributes["lar"], attributes["irproduct"])
      attributes["hhmemb"] = household_members(xml_doc, previous_status)
      (1..8).each do |index|
        attributes["age#{index}"] = safe_string_as_integer(xml_doc, "P#{index}Age")
        attributes["age#{index}_known"] = age_known(xml_doc, index, attributes["hhmemb"])
        attributes["sex#{index}"] = sex(xml_doc, index)
        attributes["ecstat#{index}"] = unsafe_string_as_integer(xml_doc, "P#{index}Eco")
      end
      (2..8).each do |index|
        attributes["relat#{index}"] = relat(xml_doc, index)
        attributes["details_known_#{index}"] = details_known(index, attributes)
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
        attributes["illness_type_#{index}"] = illness_type(xml_doc, index, attributes["illness"])
      end
      attributes["illness_type_0"] = 1 if (1..10).all? { |idx| attributes["illness_type_#{idx}"].nil? || attributes["illness_type_#{idx}"].zero? }

      attributes["prevten"] = unsafe_string_as_integer(xml_doc, "Q11")
      attributes["prevloc"] = string_or_nil(xml_doc, "Q12aONS")
      attributes["ppostcode_full"] = compose_postcode(xml_doc, "PPOSTC1", "PPOSTC2")
      attributes["previous_postcode_known"] = previous_postcode_known(xml_doc, attributes["ppostcode_full"], attributes["prevloc"])
      attributes["layear"] = unsafe_string_as_integer(xml_doc, "Q12c")
      attributes["waityear"] = unsafe_string_as_integer(xml_doc, "Q12d")
      attributes["homeless"] = unsafe_string_as_integer(xml_doc, "Q13")

      attributes["reasonpref"] = unsafe_string_as_integer(xml_doc, "Q14a")
      attributes["rp_homeless"] = unsafe_string_as_integer(xml_doc, "Q14b1").present? ? 1 : nil
      attributes["rp_insan_unsat"] = unsafe_string_as_integer(xml_doc, "Q14b2").present? ? 1 : nil
      attributes["rp_medwel"] = unsafe_string_as_integer(xml_doc, "Q14b3").present? ? 1 : nil
      attributes["rp_hardship"] = unsafe_string_as_integer(xml_doc, "Q14b4").present? ? 1 : nil
      attributes["rp_dontknow"] = unsafe_string_as_integer(xml_doc, "Q14b5").present? ? 1 : nil

      attributes["cbl"] = unsafe_string_as_integer(xml_doc, "Q15CBL").present? ? 1 : nil
      attributes["chr"] = unsafe_string_as_integer(xml_doc, "Q15CHR").present? ? 1 : nil
      attributes["cap"] = unsafe_string_as_integer(xml_doc, "Q15CAP").present? ? 1 : nil

      attributes["referral"] = unsafe_string_as_integer(xml_doc, "Q16")
      attributes["period"] = unsafe_string_as_integer(xml_doc, "Q17")

      attributes["brent"] = safe_string_as_decimal(xml_doc, "Q18ai")
      attributes["scharge"] = safe_string_as_decimal(xml_doc, "Q18aii")
      attributes["pscharge"] = safe_string_as_decimal(xml_doc, "Q18aiii")
      attributes["supcharg"] = safe_string_as_decimal(xml_doc, "Q18aiv")
      attributes["tcharge"] = safe_string_as_decimal(xml_doc, "Q18av")

      attributes["hbrentshortfall"] = unsafe_string_as_integer(xml_doc, "Q18d")
      attributes["tshortfall"] = safe_string_as_decimal(xml_doc, "Q18dyes")
      attributes["tshortfall_known"] = tshortfall_known?(xml_doc, attributes)

      attributes["voiddate"] = compose_date(xml_doc, "VDAY", "VMONTH", "VYEAR")
      attributes["mrcdate"] = compose_date(xml_doc, "MRCDAY", "MRCMONTH", "MRCYEAR")
      attributes["majorrepairs"] = if attributes["mrcdate"].present? && previous_status.include?("submitted")
                                     1
                                   elsif previous_status.include?("submitted")
                                     0
                                   end

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
      attributes["postcode_known"] = postcode_known(attributes)

      # Not specific to our form but required for consistency (present in import)
      attributes["old_form_id"] = safe_string_as_integer(xml_doc, "FORM")
      attributes["created_at"] = Time.zone.parse(field_value(xml_doc, "meta", "created-date"))
      attributes["updated_at"] = Time.zone.parse(field_value(xml_doc, "meta", "modified-date"))
      attributes["old_id"] = field_value(xml_doc, "meta", "document-id")

      # Required for our form invalidated questions (not present in import)
      attributes["previous_la_known"] = attributes["prevloc"].nil? ? 0 : 1
      attributes["is_la_inferred"] = attributes["postcode_full"].present?
      attributes["first_time_property_let_as_social_housing"] = first_time_let(attributes["rsnvac"])
      attributes["declaration"] = declaration(xml_doc)

      # Set charges to 0 if others are partially populated
      unless attributes["brent"].nil? &&
          attributes["scharge"].nil? &&
          attributes["pscharge"].nil? &&
          attributes["supcharg"].nil?
        attributes["brent"] ||= BigDecimal("0.0")
        attributes["scharge"] ||= BigDecimal("0.0")
        attributes["pscharge"] ||= BigDecimal("0.0")
        attributes["supcharg"] ||= BigDecimal("0.0")
      end

      # Handles confidential schemes
      if attributes["postcode_full"] == "******"
        attributes["postcode_known"] = 0
        attributes["postcode_full"] = nil
      end

      owner_id = field_value(xml_doc, "meta", "owner-user-id").strip
      if owner_id.present?
        attributes["created_by"] = User.find_by(old_user_id: owner_id)
      end

      apply_date_consistency!(attributes)
      apply_household_consistency!(attributes)

      case_log = save_case_log(attributes)
      compute_differences(case_log, attributes)
      check_status_completed(case_log, previous_status) unless @logs_overridden.include?(case_log.old_id)
    end

    def save_case_log(attributes)
      case_log = CaseLog.new(attributes)
      begin
        case_log.save!
        case_log
      rescue ActiveRecord::RecordNotUnique
        legacy_id = attributes["old_id"]
        record = CaseLog.find_by(old_id: legacy_id)
        @logger.info "Updating case log #{record.id} with legacy ID #{legacy_id}"
        record.update!(attributes)
        record
      rescue ActiveRecord::RecordInvalid => e
        rescue_validation_or_raise(case_log, attributes, e)
      end
    end

    def rescue_validation_or_raise(case_log, attributes, exception)
      if case_log.errors.of_kind?(:referral, :internal_transfer_non_social_housing)
        @logger.warn("Log #{case_log.old_id}: Removing internal transfer referral since previous tenancy is a non social housing")
        @logs_overridden << case_log.old_id
        attributes.delete("referral")
        save_case_log(attributes)
      elsif case_log.errors.of_kind?(:referral, :internal_transfer_fixed_or_lifetime)
        @logger.warn("Log #{case_log.old_id}: Removing internal transfer referral since previous tenancy is fixed terms or lifetime")
        @logs_overridden << case_log.old_id
        attributes.delete("referral")
        save_case_log(attributes)
      else
        raise exception
      end
    end

    def compute_differences(case_log, attributes)
      differences = []
      attributes.each do |key, value|
        case_log_value = case_log.send(key.to_sym)
        next if fields_not_present_in_softwire_data.include?(key)

        if value != case_log_value
          differences.push("#{key} #{value.inspect} #{case_log_value.inspect}")
        end
      end
      @logger.warn "Differences found when saving log #{case_log.old_id}: #{differences}" unless differences.empty?
    end

    def fields_not_present_in_softwire_data
      %w[majorrepairs illness_type_0 tshortfall_known]
    end

    def check_status_completed(case_log, previous_status)
      if previous_status.include?("submitted") && case_log.status != "completed"
        @logger.warn "Case log #{case_log.id} is not completed"
        @logger.warn "Case log with old id:#{case_log.old_id} is incomplete but status should be complete"
        @logs_with_discrepancies << case_log.old_id
      end
    end

    # Safe: A string that represents only an integer (or empty/nil)
    def safe_string_as_integer(xml_doc, attribute)
      str = field_value(xml_doc, "xmlns", attribute)
      Integer(str, exception: false)
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

    def find_organisation_id(xml_doc, id_field)
      old_visible_id = unsafe_string_as_integer(xml_doc, id_field)
      organisation = Organisation.find_by(old_visible_id:)
      raise "Organisation not found with legacy ID #{old_visible_id}" if organisation.nil?

      organisation.id
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
      when "Refused"
        "R"
      end
    end

    def age_known(xml_doc, index, hhmemb)
      return nil if hhmemb.present? && index > hhmemb

      age_refused = string_or_nil(xml_doc, "P#{index}AR")
      if age_refused.present?
        if age_refused.casecmp("AGE_REFUSED").zero?
          return 1 # No
        else
          return 0 # Yes
        end
      end
      0
    end

    def details_known(index, attributes)
      return nil if attributes["hhmemb"].nil? || index > attributes["hhmemb"]

      if attributes["age#{index}_known"] == 1 &&
          attributes["sex#{index}"] == "R" &&
          attributes["relat#{index}"] == "R" &&
          attributes["ecstat#{index}"] == 10
        1 # No
      else
        0 # Yes
      end
    end

    def previous_postcode_known(xml_doc, previous_postcode, prevloc)
      previous_postcode_known = string_or_nil(xml_doc, "Q12bnot")
      if previous_postcode_known == "Temporary_or_Unknown" || (previous_postcode.nil? && prevloc.present?)
        0
      elsif previous_postcode.nil?
        nil
      else
        1
      end
    end

    POSTCODE_REGEXP = Validations::PropertyValidations::POSTCODE_REGEXP
    def compose_postcode(xml_doc, outcode, incode)
      outcode_value = string_or_nil(xml_doc, outcode)
      incode_value = string_or_nil(xml_doc, incode)
      if outcode_value.nil? || incode_value.nil? || !"#{outcode_value}#{incode_value}".match(POSTCODE_REGEXP)
        nil
      else
        "#{outcode_value}#{incode_value}"
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
        17
      end
    end

    # Letters should be lowercase to match case
    def housing_needs(xml_doc, letter)
      housing_need = string_or_nil(xml_doc, "Q10-#{letter}")
      if housing_need == "Yes"
        1
      else
        0
      end
    end

    def net_income_known(xml_doc, earnings)
      incref = string_or_nil(xml_doc, "Q8Refused")
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

    def illness_type(xml_doc, index, illness)
      illness_type = string_or_nil(xml_doc, "Q10ib-#{index}")
      if illness_type == "Yes" && illness == 1
        1
      elsif illness == 1
        0
      end
    end

    def first_time_let(rsnvac)
      if [15, 16, 17].include?(rsnvac)
        1
      else
        0
      end
    end

    def declaration(xml_doc)
      declaration = string_or_nil(xml_doc, "Qdp")
      if declaration == "Yes"
        1
      end
    end

    def postcode_known(attributes)
      if attributes["postcode_full"].nil? && attributes["la"].nil?
        nil
      elsif attributes["postcode_full"].nil?
        0 # Assumes we selected No in the form since the LA is present
      else
        1
      end
    end

    def household_members(xml_doc, previous_status)
      hhmemb = safe_string_as_integer(xml_doc, "HHMEMB")
      if previous_status.include?("submitted") && hhmemb.nil?
        hhmemb = people_with_details(xml_doc).count
        return nil if hhmemb.zero?
      end
      hhmemb
    end

    def people_with_details(xml_doc)
      ((2..8).map { |x| string_or_nil(xml_doc, "P#{x}Rel") } + [string_or_nil(xml_doc, "P1Sex")]).compact
    end

    def tshortfall_known?(xml_doc, attributes)
      if attributes["tshortfall"].blank? && attributes["hbrentshortfall"] == 1 && overridden?(xml_doc, "xmlns", "Q18dyes")
        1
      else
        0
      end
    end

    def apply_date_consistency!(attributes)
      return if attributes["voiddate"].nil? || attributes["startdate"].nil?

      if attributes["voiddate"] > attributes["startdate"]
        attributes.delete("voiddate")
      end
    end

    def apply_household_consistency!(attributes)
      (2..8).each do |index|
        next if attributes["age#{index}"].nil?

        if attributes["age#{index}"] < 16 && attributes["relat#{index}"] == "R"
          attributes["relat#{index}"] = "C"
        end
      end
    end
  end
end
