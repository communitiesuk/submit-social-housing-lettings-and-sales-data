require 'securerandom'
require 'json'

module Imports
  class LettingsLogsImportService < ImportService
    def initialize(storage_service, logger = Rails.logger)
      super
    end

    def create_logs(folder)
      @run_id = "LLRun-#{Time.zone.now.to_s}"
      @logger.info("START: Importing Lettings Logs @ #{Time.zone.now.strftime('%d-%m-%Y %H:%M')}. RunId: #{@run_id}")
      
      import_from(folder, :enqueue_job)

      @logger.info("FINISH: Importing Lettings Logs @ #{Time.zone.now.strftime('%d-%m-%Y %H:%M')}. RunId: #{@run_id}")
    end
    
    def enqueue_job(xml_document)
      LettingsLogImportJob.perform_later(@run_id, xml_document.to_s)      
    end
  end

  class LettingsLogsImportProcessor
    FORM_NAME_INDEX = {
      start_year: 0,
      rent_type: 2,
      needs_type: 3,
    }.freeze

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

    SEX = {
      "Male" => "M",
      "Female" => "F",
      "Other" => "X",
      "Non-binary" => "X",
      "Refused" => "R",
    }.freeze

    RELATION = {
      "Child" => "C",
      "Partner" => "P",
      "Other" => "X",
      "Non-binary" => "X",
      "Refused" => "R",
    }.freeze 

    FIELDS_NOT_PRESENT_IN_SOFTWIRE_DATA = %w[
      majorrepairs 
      illness_type_0 
      tshortfall_known 
      pregnancy_value_check 
      retirement_value_check 
      rent_value_check 
      net_income_value_check 
      major_repairs_date_value_check void_date_value_check 
      housingneeds_type 
      housingneeds_other
    ].freeze

    attr_reader :xml_doc, :logs_overridden, :discrepancy, :old_id
  
    def initialize(xml_document)
      @xml_doc = xml_document
      @discrepancy = false
      @old_id = ''
      @logs_overridden = false
    end    

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
      attributes["tenancycode"] = string_or_nil(xml_doc, "_2bTenCode")
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

        # Trips validation
        if attributes["age#{index}"].present? && attributes["age#{index}"] < 16 && attributes["relat#{index}"].present? && attributes["relat#{index}"] != "C" && attributes["relat#{index}"] != "R"
          attributes["age#{index}"] = nil
          attributes["relat#{index}"] = nil
        end
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
      attributes["housingneeds"] = 1 if [attributes["housingneeds_a"], attributes["housingneeds_b"], attributes["housingneeds_c"], attributes["housingneeds_f"]].any? { |housingneed| housingneed == 1 }
      attributes["housingneeds"] = 2 if attributes["housingneeds_g"] == 1
      attributes["housingneeds"] = 3 if attributes["housingneeds_h"] == 1
      attributes["housingneeds_type"] = 0 if attributes["housingneeds_a"] == 1
      attributes["housingneeds_type"] = 1 if attributes["housingneeds_b"] == 1
      attributes["housingneeds_type"] = 2 if attributes["housingneeds_c"] == 1
      attributes["housingneeds_type"] = 3 if attributes["housingneeds_f"] == 1 && [attributes["housingneeds_a"], attributes["housingneeds_b"], attributes["housingneeds_c"]].all? { |housingneed| housingneed != 1 }
      attributes["housingneeds_other"] = attributes["housingneeds_f"] == 1 ? 1 : 0

      attributes["illness"] = unsafe_string_as_integer(xml_doc, "Q10ia")
      (1..10).each do |index|
        attributes["illness_type_#{index}"] = illness_type(xml_doc, index, attributes["illness"])
      end
      attributes["illness_type_0"] = 1 if (1..10).all? { |idx| attributes["illness_type_#{idx}"].nil? || attributes["illness_type_#{idx}"].zero? }

      attributes["prevten"] = unsafe_string_as_integer(xml_doc, "Q11")
      attributes["prevloc"] = string_or_nil(xml_doc, "Q12aONS")
      attributes["ppostcode_full"] = compose_postcode(xml_doc, "PPOSTC1", "PPOSTC2")
      attributes["ppcodenk"] = previous_postcode_known(xml_doc, attributes["ppostcode_full"], attributes["prevloc"])
      attributes["layear"] = unsafe_string_as_integer(xml_doc, "Q12c")
      attributes["waityear"] = unsafe_string_as_integer(xml_doc, "Q12d")
      attributes["homeless"] = unsafe_string_as_integer(xml_doc, "Q13")

      attributes["reasonpref"] = unsafe_string_as_integer(xml_doc, "Q14a")
      attributes["rp_homeless"] = unsafe_string_as_integer(xml_doc, "Q14b1").present? ? 1 : nil
      attributes["rp_insan_unsat"] = unsafe_string_as_integer(xml_doc, "Q14b2").present? ? 1 : nil
      attributes["rp_medwel"] = unsafe_string_as_integer(xml_doc, "Q14b3").present? ? 1 : nil
      attributes["rp_hardship"] = unsafe_string_as_integer(xml_doc, "Q14b4").present? ? 1 : nil
      attributes["rp_dontknow"] = unsafe_string_as_integer(xml_doc, "Q14b5").present? ? 1 : nil

      # Trips validation
      if attributes["homeless"] == 1 && attributes["rp_homeless"] == 1
        attributes["homeless"] = nil
        attributes["rp_homeless"] = nil
      end

      attributes["cbl"] = allocation_system(unsafe_string_as_integer(xml_doc, "Q15CBL"))
      attributes["chr"] = allocation_system(unsafe_string_as_integer(xml_doc, "Q15CHR"))
      attributes["cap"] = allocation_system(unsafe_string_as_integer(xml_doc, "Q15CAP"))
      attributes["letting_allocation_unknown"] = allocation_system_unknown(attributes["cbl"], attributes["chr"], attributes["cap"])

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
      @old_id = attributes["old_id"]

      # Required for our form invalidated questions (not present in import)
      attributes["previous_la_known"] = attributes["prevloc"].nil? ? 0 : 1
      attributes["is_la_inferred"] = attributes["postcode_full"].present?
      attributes["first_time_property_let_as_social_housing"] = first_time_let(attributes["rsnvac"])
      attributes["declaration"] = declaration(xml_doc)

      set_partial_charges_to_zero(attributes)

      # Supported Housing fields
      if attributes["needstype"] == GN_SH[:supported_housing]
        location_old_visible_id = safe_string_as_integer(xml_doc, "_1cschemecode")
        scheme_old_visible_id = safe_string_as_integer(xml_doc, "_1cmangroupcode")

        schemes = Scheme.where(old_visible_id: scheme_old_visible_id, owning_organisation_id: attributes["owning_organisation_id"])
        location = Location.find_by(old_visible_id: location_old_visible_id, scheme: schemes)
        raise "No matching location for scheme #{scheme_old_visible_id} and location #{location_old_visible_id} (visible IDs)" if location.nil?

        # Set the scheme via location, because the scheme old visible ID can be duplicated at import
        attributes["location_id"] = location.id
        attributes["scheme_id"] = location.scheme.id
        attributes["sheltered"] = unsafe_string_as_integer(xml_doc, "Q1e")
        attributes["chcharge"] = safe_string_as_decimal(xml_doc, "Q18b")
        attributes["household_charge"] = household_charge(xml_doc)
        attributes["is_carehome"] = is_carehome(location.scheme)
      end

      # Handles confidential schemes
      if attributes["postcode_full"] == "******"
        attributes["postcode_known"] = 0
        attributes["postcode_full"] = nil
      end

      # Soft validations can become required answers, set them to yes by default
      attributes["pregnancy_value_check"] = 0
      attributes["major_repairs_date_value_check"] = 0
      attributes["void_date_value_check"] = 0
      attributes["retirement_value_check"] = 0
      attributes["rent_value_check"] = 0
      attributes["net_income_value_check"] = 0

      # Sets the log creator
      owner_id = field_value(xml_doc, "meta", "owner-user-id").strip
      if owner_id.present?
        user = LegacyUser.find_by(old_user_id: owner_id)&.user
        @logger.warn "Missing user! We expected to find a legacy user with old_user_id #{owner_id}" unless user

        attributes["created_by"] = user
      end
 
      apply_date_consistency!(attributes)
      apply_household_consistency!(attributes)

      lettings_log = save_lettings_log(attributes)
      compute_differences(lettings_log, attributes)
      check_status_completed(lettings_log, previous_status)
    end

    def save_lettings_log(attributes)
      lettings_log = LettingsLog.new(attributes)
      begin
        lettings_log.save!
        lettings_log
      rescue ActiveRecord::RecordNotUnique
        legacy_id = attributes["old_id"]
        record = LettingsLog.find_by(old_id: legacy_id)
        @logger.info "Updating lettings log #{record.id} with legacy ID #{legacy_id}"
        record.update!(attributes)
        record
      rescue ActiveRecord::RecordInvalid => e
        rescue_validation_or_raise(lettings_log, attributes, e)
      end
    end

    def rescue_validation_or_raise(lettings_log, attributes, exception)
      if lettings_log.errors.of_kind?(:referral, :internal_transfer_non_social_housing)
        @logger.warn("Log #{lettings_log.old_id}: Removing internal transfer referral since previous tenancy is a non social housing")
        @logs_overridden = true
        attributes.delete("referral")
        save_lettings_log(attributes)
      elsif lettings_log.errors.of_kind?(:referral, :internal_transfer_fixed_or_lifetime)
        @logger.warn("Log #{lettings_log.old_id}: Removing internal transfer referral since previous tenancy is fixed terms or lifetime")
        @logs_overridden = true
        attributes.delete("referral")
        save_lettings_log(attributes)
      else
        @logger.error("[rescue_validation_or_raise] No actionable error for exception: #{exception.message}")
        raise exception
      end
    end

    def compute_differences(lettings_log, attributes)
      differences = []
      attributes.each do |key, value|
        lettings_log_value = lettings_log.send(key.to_sym)
        next if FIELDS_NOT_PRESENT_IN_SOFTWIRE_DATA.include?(key)

        if value != lettings_log_value
          differences.push("#{key} #{value.inspect} #{lettings_log_value.inspect}")
        end
      end
      @logger.warn "Differences found when saving log #{lettings_log.old_id}: #{differences}" unless differences.empty?
    end

    # @logs_overridden can only include?(lettings_log.old_id) if there was a
    # validation error raised therefore no need to do @logs_overridden.include? but rather 
    # enough to set a flag for logs_overriden  
    def check_status_completed(lettings_log, previous_status)
      return if @logs_overridden

      if previous_status.include?("submitted") && lettings_log.status != "completed"
        @logger.warn "DISCREPENCY lettings log #{lettings_log.id} is not completed"
        @logger.warn "DISCREPENCY lettings log with old id:#{lettings_log.old_id} is incomplete but status should be complete"
        @discrepancy = true
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
      return if str.nil?
      
      BigDecimal(str, exception: false)
    end

    # Unsafe: A string that has more than just the integer value
    def unsafe_string_as_integer(xml_doc, attribute)
      str = string_or_nil(xml_doc, attribute)
      return if str.nil?
      
      str.to_i
    end

    def compose_date(xml_doc, day_str, month_str, year_str)
      day = Integer(field_value(xml_doc, "xmlns", day_str), exception: false)
      month = Integer(field_value(xml_doc, "xmlns", month_str), exception: false)
      year = Integer(field_value(xml_doc, "xmlns", year_str), exception: false)

      return if [day, month, year].any?(&:nil?)
      
      Time.zone.local(year, month, day)      
    end

    def get_form_name_component(xml_doc, index)
      form_name = field_value(xml_doc, "meta", "form-name")
      form_type_components = form_name.split("-")
      form_type_components[index]
    end

    def needs_type(xml_doc)
      gn_sh = get_form_name_component(xml_doc, FORM_NAME_INDEX[:needs_type])

      case gn_sh
      when "GN"
        GN_SH[:general_needs]
      when "SH"
        GN_SH[:supported_housing]
      else
        raise "Unknown needstype value: #{gn_sh}"
      end
    end

    # This does not match renttype (CDS) which is derived by lettings log logic
    def rent_type(xml_doc, lar, irproduct)
      sr_ar_ir = get_form_name_component(xml_doc, FORM_NAME_INDEX[:rent_type])

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
      unmapped_sex = string_or_nil(xml_doc, "P#{index}Sex")
      SEX[unmapped_sex]
    end

    def relat(xml_doc, index)
      unmapped_relation = string_or_nil(xml_doc, "P#{index}Rel")
      RELATION[unmapped_relation]
    end

    def age_known(xml_doc, index, hhmemb)
      return nil if hhmemb.present? && index > hhmemb

      age_refused = string_or_nil(xml_doc, "P#{index}AR")
      return 0 unless age_refused.present?
      
      (age_refused.casecmp?("AGE_REFUSED") || age_refused.casecmp?("No")) ? 1 : 0
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

    def compose_postcode(xml_doc, outcode, incode)
      outcode_value = string_or_nil(xml_doc, outcode)
      incode_value = string_or_nil(xml_doc, incode)
      
      if outcode_value.nil? || incode_value.nil? || !"#{outcode_value} #{incode_value}".match(POSTCODE_REGEXP)
        nil
      else
        "#{outcode_value} #{incode_value}"
      end
    end
    
    # Default to No (2) for any other values (nil, not known)
    def london_affordable_rent(xml_doc)      
      unsafe_string_as_integer(xml_doc, "LAR") == 1 ? 1 : 2
    end

    #  Relet – renewal of fixed-term tenancy
    def renewal(rsnvac)      
      rsnvac == 14 ? 1 : 0
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
      string_or_nil(xml_doc, "Q10-#{letter}") == "Yes" ? 1 : 0
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
      string_or_nil(xml_doc, "Q10ib-#{index}") == "Yes" && illness == 1 ? 1 : 0
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

    def allocation_system(value)     
      value == 1 ? 1 : 0 
    end

    def allocation_system_unknown(cbl, chr, cap)
      allocation_values = [cbl, chr, cap]

      if allocation_values.all?(&:nil?)
        nil
      elsif allocation_values.all? { |att| att&.zero? }
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

    def household_charge(xml_doc)
      value = string_or_nil(xml_doc, "Q18c")
      start_year = Integer(get_form_name_component(xml_doc, FORM_NAME_INDEX[:start_year]))

      if start_year <= 2021
        # Yes means that there are no charges (2021 or earlier)
        value && value.include?("Yes") ? 1 : 0
      else
        # Yes means that there are charges (2022 onwards)
        value && value.include?("Yes") ? 0 : 1
      end
    end

    def set_partial_charges_to_zero(attributes)
      unless attributes["brent"].nil? &&
          attributes["scharge"].nil? &&
          attributes["pscharge"].nil? &&
          attributes["supcharg"].nil?
        attributes["brent"] ||= BigDecimal("0.0")
        attributes["scharge"] ||= BigDecimal("0.0")
        attributes["pscharge"] ||= BigDecimal("0.0")
        attributes["supcharg"] ||= BigDecimal("0.0")
      end
    end

    def is_carehome(scheme)
      return nil unless scheme

      if [2, 3, 4].include?(scheme.registered_under_care_act_before_type_cast)
        1
      else
        0
      end
    end

    def discrepancy?
      !!@discrepancy
    end    
  end
end
