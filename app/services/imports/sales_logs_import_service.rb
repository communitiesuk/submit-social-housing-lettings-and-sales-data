module Imports
  class SalesLogsImportService < LogsImportService
    def initialize(storage_service, logger = Rails.logger)
      @logs_with_discrepancies = Set.new
      @logs_overridden = Set.new
      super
    end

    def create_logs(folder)
      import_from(folder, :create_log)
      if @logs_with_discrepancies.count.positive?
        @logger.warn("The following sales logs had status discrepancies: [#{@logs_with_discrepancies.join(', ')}]")
      end
    end

  private

    def create_log(xml_doc)
      # only import sales logs from 22/23 collection period onwards
      return unless meta_field_value(xml_doc, "form-name").include?("Sales")
      return unless compose_date(xml_doc, "DAY", "MONTH", "YEAR") >= Time.zone.local(2022, 4, 1)

      attributes = {}

      previous_status = meta_field_value(xml_doc, "status")

      # Required fields for status complete or logic to work
      # Note: order matters when we derive from previous values (attributes parameter)

      attributes["saledate"] = compose_date(xml_doc, "DAY", "MONTH", "YEAR")
      attributes["owning_organisation_id"] = find_organisation_id(xml_doc, "OWNINGORGID")
      attributes["type"] = unsafe_string_as_integer(xml_doc, "DerSaleType")
      attributes["old_id"] = meta_field_value(xml_doc, "document-id")
      attributes["created_at"] = Time.zone.parse(meta_field_value(xml_doc, "created-date"))
      attributes["updated_at"] = Time.zone.parse(meta_field_value(xml_doc, "modified-date"))
      attributes["purchid"] = string_or_nil(xml_doc, "PurchaserCode")
      attributes["ownershipsch"] = unsafe_string_as_integer(xml_doc, "Ownership")
      attributes["ownershipsch"] = ownership_from_type(attributes) if attributes["ownershipsch"].blank? # sometimes Ownership is missing, but type is set
      attributes["othtype"] = string_or_nil(xml_doc, "Q38OtherSale")
      attributes["jointpur"] = unsafe_string_as_integer(xml_doc, "joint")
      attributes["jointmore"] = unsafe_string_as_integer(xml_doc, "JointMore") || 3 if attributes["jointpur"] == 1
      attributes["beds"] = safe_string_as_integer(xml_doc, "Q11Bedrooms")
      attributes["companybuy"] = unsafe_string_as_integer(xml_doc, "company") if attributes["ownershipsch"] == 3
      attributes["hholdcount"] = other_household_members(xml_doc, attributes)
      attributes["hhmemb"] = household_members(xml_doc, attributes)
      (1..6).each do |index|
        attributes["age#{index}"] = safe_string_as_integer(xml_doc, "P#{index}Age")
        attributes["sex#{index}"] = sex(xml_doc, index)
        attributes["ecstat#{index}"] = unsafe_string_as_integer(xml_doc, "P#{index}Eco")
        attributes["age#{index}_known"] = age_known(xml_doc, index, attributes["hhmemb"], attributes["age#{index}"])
      end
      (2..6).each do |index|
        attributes["relat#{index}"] = relat(xml_doc, index)
        attributes["details_known_#{index}"] = details_known(index, attributes)
      end
      attributes["national"] = unsafe_string_as_integer(xml_doc, "P1Nat")
      attributes["ethnic"] = unsafe_string_as_integer(xml_doc, "P1Eth")
      attributes["ethnic_group"] = ethnic_group(attributes["ethnic"])
      attributes["buy1livein"] = unsafe_string_as_integer(xml_doc, "LiveInBuyer1")
      attributes["buylivein"] = unsafe_string_as_integer(xml_doc, "LiveInBuyer") if attributes["ownershipsch"] == 3
      attributes["builtype"] = unsafe_string_as_integer(xml_doc, "Q13BuildingType")
      attributes["proptype"] = unsafe_string_as_integer(xml_doc, "Q12PropertyType")
      attributes["privacynotice"] = 1 if string_or_nil(xml_doc, "Qdp") == "Yes"
      attributes["noint"] = unsafe_string_as_integer(xml_doc, "PartAPurchaser")
      attributes["buy2livein"] = unsafe_string_as_integer(xml_doc, "LiveInBuyer2")
      attributes["wheel"] = unsafe_string_as_integer(xml_doc, "Q10Wheelchair")
      attributes["la"] = string_or_nil(xml_doc, "Q14ONSLACode")
      attributes["income1"] = safe_string_as_integer(xml_doc, "Q2Person1Income")
      attributes["income1nk"] = income_known(unsafe_string_as_integer(xml_doc, "P1IncKnown"))
      attributes["inc1mort"] = unsafe_string_as_integer(xml_doc, "Q2Person1Mortgage")
      attributes["income2"] = safe_string_as_integer(xml_doc, "Q2Person2Income")
      attributes["income2nk"] = income_known(unsafe_string_as_integer(xml_doc, "P2IncKnown"))
      attributes["savings"] = safe_string_as_integer(xml_doc, "Q3Savings")
      attributes["savingsnk"] = savings_known(xml_doc)
      attributes["prevown"] = unsafe_string_as_integer(xml_doc, "Q4PrevOwnedProperty")
      attributes["mortgage"] = safe_string_as_decimal(xml_doc, "CALCMORT")
      attributes["inc2mort"] = unsafe_string_as_integer(xml_doc, "Q2Person2MortApplication")
      attributes["hb"] = unsafe_string_as_integer(xml_doc, "Q2a")
      attributes["frombeds"] = safe_string_as_integer(xml_doc, "Q20Bedrooms")
      attributes["staircase"] = unsafe_string_as_integer(xml_doc, "Q17aStaircase") if attributes["ownershipsch"] == 1
      attributes["stairbought"] = safe_string_as_integer(xml_doc, "PercentBought")
      attributes["stairowned"] = safe_string_as_integer(xml_doc, "PercentOwns") if attributes["staircase"] == 1
      attributes["mrent"] = safe_string_as_decimal(xml_doc, "Q28MonthlyRent")
      attributes["exdate"] = compose_date(xml_doc, "EXDAY", "EXMONTH", "EXYEAR")
      attributes["exday"] = safe_string_as_integer(xml_doc, "EXDAY")
      attributes["exmonth"] = safe_string_as_integer(xml_doc, "EXMONTH")
      attributes["exyear"] = safe_string_as_integer(xml_doc, "EXYEAR")
      attributes["resale"] = unsafe_string_as_integer(xml_doc, "Q17Resale")
      attributes["deposit"] = deposit(xml_doc, attributes)
      attributes["cashdis"] = safe_string_as_decimal(xml_doc, "Q27SocialHomeBuy")
      attributes["disabled"] = unsafe_string_as_integer(xml_doc, "Disability")
      attributes["lanomagr"] = unsafe_string_as_integer(xml_doc, "Q19Rehoused")
      attributes["value"] = purchase_price(xml_doc, attributes)
      attributes["equity"] = safe_string_as_decimal(xml_doc, "Q23Equity")
      attributes["discount"] = safe_string_as_decimal(xml_doc, "Q33Discount")
      attributes["grant"] = safe_string_as_decimal(xml_doc, "Q32Reductions")
      attributes["pregyrha"] = 1 if string_or_nil(xml_doc, "PREGYRHA") == "Yes"
      attributes["pregla"] = 1 if string_or_nil(xml_doc, "PREGLA") == "Yes"
      attributes["pregghb"] = 1 if string_or_nil(xml_doc, "PREGHBA") == "Yes"
      attributes["pregother"] = 1 if string_or_nil(xml_doc, "PREGOTHER") == "Yes"
      attributes["ppostcode_full"] = parse_postcode(string_or_nil(xml_doc, "Q7Postcode"))
      attributes["prevloc"] = string_or_nil(xml_doc, "Q7ONSLACode")
      attributes["ppcodenk"] = previous_postcode_known(xml_doc, attributes["ppostcode_full"], attributes["prevloc"]) # Q7UNKNOWNPOSTCODE check mapping
      attributes["ppostc1"] = string_or_nil(xml_doc, "PPOSTC1")
      attributes["ppostc2"] = string_or_nil(xml_doc, "PPOSTC2")
      attributes["hhregres"] = unsafe_string_as_integer(xml_doc, "ArmedF")
      attributes["hhregresstill"] = still_serving(xml_doc)
      attributes["proplen"] = safe_string_as_integer(xml_doc, "Q16aProplen2") || safe_string_as_integer(xml_doc, "Q16aProplensec2")
      attributes["mscharge"] = monthly_charges(xml_doc, attributes)
      attributes["has_mscharge"] = 1 if attributes["mscharge"]&.positive?
      attributes["has_mscharge"] = 0 if attributes["mscharge"].present? && attributes["mscharge"] <= 0
      attributes["prevten"] = unsafe_string_as_integer(xml_doc, "Q6PrevTenure")
      attributes["mortlen"] = mortgage_length(xml_doc, attributes)
      attributes["extrabor"] = borrowing(xml_doc, attributes)
      attributes["mortgageused"] = mortgage_used(xml_doc, attributes)
      attributes["wchair"] = unsafe_string_as_integer(xml_doc, "Q15Wheelchair")
      attributes["armedforcesspouse"] = unsafe_string_as_integer(xml_doc, "ARMEDFORCESSPOUSE")
      attributes["hodate"] = compose_date(xml_doc, "HODAY", "HOMONTH", "HOYEAR")
      attributes["hoday"] = safe_string_as_integer(xml_doc, "HODAY")
      attributes["homonth"] = safe_string_as_integer(xml_doc, "HOMONTH")
      attributes["hoyear"] = safe_string_as_integer(xml_doc, "HOYEAR")
      attributes["fromprop"] = unsafe_string_as_integer(xml_doc, "Q21PropertyType")
      attributes["socprevten"] = unsafe_string_as_integer(xml_doc, "PrevRentType")
      attributes["mortgagelender"] = mortgage_lender(xml_doc, attributes)
      attributes["mortgagelenderother"] = mortgage_lender_other(xml_doc, attributes)
      attributes["postcode_full"] = parse_postcode(string_or_nil(xml_doc, "Q14Postcode"))
      attributes["pcodenk"] = 0 if attributes["postcode_full"].present? # known if given
      attributes["soctenant"] = 0 if attributes["ownershipsch"] == 1
      attributes["ethnic_group2"] = nil # 23/24 variable
      attributes["ethnicbuy2"] = nil # 23/24 variable
      attributes["prevshared"] = nil # 23/24 variable
      attributes["staircasesale"] = nil # 23/24 variable

      attributes["previous_la_known"] = 1 if attributes["prevloc"].present?
      if attributes["la"].present?
        attributes["la_known"] = 1
        attributes["is_la_inferred"] = false
      end

      # Soft validations can become required answers, set them to yes by default
      attributes["mortgage_value_check"] = 0
      attributes["shared_ownership_deposit_value_check"] = 0
      attributes["value_value_check"] = 0
      attributes["savings_value_check"] = 0
      attributes["income1_value_check"] = 0
      attributes["deposit_value_check"] = 0
      attributes["wheel_value_check"] = 0
      attributes["retirement_value_check"] = 0
      attributes["extrabor_value_check"] = 0
      attributes["grant_value_check"] = 0
      attributes["staircase_bought_value_check"] = 0
      attributes["deposit_and_mortgage_value_check"] = 0
      attributes["old_persons_shared_ownership_value_check"] = 0
      attributes["income2_value_check"] = 0
      attributes["monthly_charges_value_check"] = 0
      attributes["student_not_child_value_check"] = 0
      attributes["discounted_sale_value_check"] = 0
      attributes["buyer_livein_value_check"] = 0
      attributes["percentage_discount_value_check"] = 0

      if attributes["saledate"] >= Time.zone.local(2023, 4, 1)
        attributes["uprn"] = string_or_nil(xml_doc, "UPRN")
        attributes["uprn_known"] = attributes["uprn"].present? ? 1 : 0
        attributes["uprn_confirmed"] = attributes["uprn"].present? ? 1 : 0
        attributes["address_line1"] = string_or_nil(xml_doc, "AddressLine1")
        attributes["address_line2"] = string_or_nil(xml_doc, "AddressLine2")
        attributes["town_or_city"] = string_or_nil(xml_doc, "TownCity")
        attributes["county"] = string_or_nil(xml_doc, "County")
      end

      # Sets the log creator
      owner_id = meta_field_value(xml_doc, "owner-user-id").strip
      if owner_id.present?
        user = LegacyUser.find_by(old_user_id: owner_id)&.user
        @logger.warn "Missing user! We expected to find a legacy user with old_user_id #{owner_id}" unless user

        attributes["created_by"] = user
      end

      set_default_values(attributes) if previous_status.include?("submitted")
      sales_log = save_sales_log(attributes, previous_status)
      compute_differences(sales_log, attributes)
      check_status_completed(sales_log, previous_status) unless @logs_overridden.include?(sales_log.old_id)
    end

    def save_sales_log(attributes, previous_status)
      sales_log = SalesLog.new(attributes)
      begin
        sales_log.save!
        sales_log
      rescue ActiveRecord::RecordNotUnique
        legacy_id = attributes["old_id"]
        record = SalesLog.find_by(old_id: legacy_id)
        @logger.info "Updating sales log #{record.id} with legacy ID #{legacy_id}"
        record.update!(attributes)
        record
      rescue ActiveRecord::RecordInvalid => e
        rescue_validation_or_raise(sales_log, attributes, previous_status, e)
      end
    end

    def rescue_validation_or_raise(sales_log, attributes, previous_status, exception)
      if %w[saved submitted-invalid].include?(previous_status)
        sales_log.errors.each do |error|
          unless error.attribute == :type || error.attribute == :ownershipsch
            @logger.warn("Log #{sales_log.old_id}: Removing field #{error.attribute} from log triggering validation: #{error.type}")
            attributes.delete(error.attribute.to_s)
          end
          attributes.delete("pcodenk") if error.attribute == :postcode_full
          attributes.delete("ppcodenk") if error.attribute == :ppostcode_full
        end
        @logs_overridden << sales_log.old_id
        save_sales_log(attributes, previous_status)
      elsif sales_log.errors.of_kind?(:postcode_full, :postcodes_not_matching)
        @logger.warn("Log #{sales_log.old_id}: Removing previous postcode known and previous postcode as the postcode is invalid")
        @logs_overridden << sales_log.old_id
        attributes.delete("ppcodenk")
        attributes.delete("ppostcode_full")
        save_sales_log(attributes, previous_status)
      elsif sales_log.errors.of_kind?(:exdate, :over_a_year_from_saledate)
        @logger.warn("Log #{sales_log.old_id}: Removing exchange date as the exchange date is invalid")
        @logs_overridden << sales_log.old_id
        attributes.delete("exdate")
        save_sales_log(attributes, previous_status)
      elsif sales_log.errors.of_kind?(:income1, :over_hard_max_for_outside_london)
        @logger.warn("Log #{sales_log.old_id}: Removing income1 as the income1 is invalid")
        @logs_overridden << sales_log.old_id
        attributes.delete("income1")
        save_sales_log(attributes, previous_status)
      elsif sales_log.errors.of_kind?(:equity, :over_max) || sales_log.errors.of_kind?(:equity, :under_min)
        @logger.warn("Log #{sales_log.old_id}: Removing equity as the equity is invalid")
        @logs_overridden << sales_log.old_id
        attributes.delete("equity")
        save_sales_log(attributes, previous_status)
      elsif sales_log.errors.of_kind?(:postcode_full, :wrong_format)
        @logger.warn("Log #{sales_log.old_id}: Removing postcode as the postcode is invalid")
        @logs_overridden << sales_log.old_id
        attributes.delete("postcode_full")
        attributes["pcodenk"] = attributes["la"].present? ? 1 : nil
        save_sales_log(attributes, previous_status)
      elsif sales_log.errors.of_kind?(:mortgage, :cannot_be_0)
        @logger.warn("Log #{sales_log.old_id}: Removing mortgage because it cannot be 0")
        @logs_overridden << sales_log.old_id
        attributes.delete("mortgage")
        save_sales_log(attributes, previous_status)
      elsif sales_log.errors.of_kind?(:uprn, :uprn_error)
        @logger.warn("Log #{sales_log.old_id}: Setting uprn_known to no with error: #{sales_log.errors[:uprn].join(', ')}")
        @logs_overridden << sales_log.old_id
        attributes["uprn_known"] = 0
        save_sales_log(attributes, previous_status)
      else
        @logger.error("Log #{sales_log.old_id}: Failed to import")
        sales_log.errors.each do |error|
          @logger.error("Validation error: Field #{error.attribute}:")
          @logger.error("\tOwning Organisation: #{sales_log.owning_organisation&.name}")
          @logger.error("\tOld CORE ID: #{sales_log.old_id}")
          @logger.error("\tOld CORE: #{attributes[error.attribute.to_s]&.inspect}")
          @logger.error("\tNew CORE: #{sales_log.read_attribute(error.attribute)&.inspect}")
          @logger.error("\tError message: #{error.type}")
        end
        raise exception
      end
    end

    def compute_differences(sales_log, attributes)
      differences = []
      attributes.each do |key, value|
        sales_log_value = sales_log.send(key.to_sym)
        next if fields_not_present_in_softwire_data.include?(key)

        if value != sales_log_value
          differences.push("#{key} #{value.inspect} #{sales_log_value.inspect}")
        end
      end
      @logger.warn "Differences found when saving log #{sales_log.old_id}: #{differences}" unless differences.empty?
    end

    def fields_not_present_in_softwire_data
      %w[created_by
         income1_value_check
         income2_value_check
         mortgage_value_check
         savings_value_check
         deposit_value_check
         wheel_value_check
         retirement_value_check
         extrabor_value_check
         deposit_and_mortgage_value_check
         shared_ownership_deposit_value_check
         grant_value_check
         value_value_check
         old_persons_shared_ownership_value_check
         staircase_bought_value_check
         monthly_charges_value_check
         hodate_check
         saledate_check
         student_not_child_value_check
         discounted_sale_value_check
         buyer_livein_value_check
         percentage_discount_value_check]
    end

    def check_status_completed(sales_log, previous_status)
      if previous_status.include?("submitted") && sales_log.status != "completed"
        @logger.warn "sales log #{sales_log.id} is not completed. The following answers are missing: #{missing_answers(sales_log).join(', ')}"
        @logger.warn "sales log with old id:#{sales_log.old_id} is incomplete but status should be complete"
        @logs_with_discrepancies << sales_log.old_id
      end
    end

    def age_known(_xml_doc, index, hhmemb, age)
      return nil if hhmemb.present? && index > hhmemb

      return 0 if age.present?
    end

    def details_known(index, attributes)
      return nil if attributes["hhmemb"].nil? || index > attributes["hhmemb"]
      return nil if attributes["jointpur"] == 1 && index == 2

      if attributes["age#{index}_known"] != 0 &&
          attributes["sex#{index}"] == "R" &&
          attributes["relat#{index}"] == "R" &&
          attributes["ecstat#{index}"] == 10
        2 # No
      else
        1 # Yes
      end
    end

    MORTGAGE_LENDER_OPTIONS = {
      "atom bank" => 1,
      "barclays bank plc" => 2,
      "bath building society" => 3,
      "buckinghamshire building society" => 4,
      "cambridge building society" => 5,
      "coventry building society" => 6,
      "cumberland building society" => 7,
      "darlington building society" => 8,
      "dudley building society" => 9,
      "ecology building society" => 10,
      "halifax" => 11,
      "hanley economic building society" => 12,
      "hinckley and rugby building society" => 13,
      "holmesdale building society" => 14,
      "ipswich building society" => 15,
      "leeds building society" => 16,
      "lloyds bank" => 17,
      "mansfield building society" => 18,
      "market harborough building society" => 19,
      "melton mowbray building society" => 20,
      "nationwide building society" => 21,
      "natwest" => 22,
      "nedbank private wealth" => 23,
      "newbury building society" => 24,
      "oneSavings bank" => 25,
      "parity trust" => 26,
      "penrith building society" => 27,
      "pepper homeloans" => 28,
      "royal bank of scotland" => 29,
      "santander" => 30,
      "skipton building society" => 31,
      "teachers building society" => 32,
      "the co-operative bank" => 33,
      "tipton & coseley building society" => 34,
      "tss" => 35,
      "ulster bank" => 36,
      "virgin money" => 37,
      "west bromwich building society" => 38,
      "yorkshire building society" => 39,
      "other" => 40,
    }.freeze

    # this comes through as a string, need to map to a corresponding integer
    def mortgage_lender(xml_doc, attributes)
      lender = case attributes["ownershipsch"]
               when 1
                 string_or_nil(xml_doc, "Q24aMortgageLender")
               when 2
                 string_or_nil(xml_doc, "Q34a")
               when 3
                 string_or_nil(xml_doc, "Q41aMortgageLender")
               end
      return if lender.blank?

      MORTGAGE_LENDER_OPTIONS[lender.downcase] || MORTGAGE_LENDER_OPTIONS["other"]
    end

    def mortgage_lender_other(xml_doc, attributes)
      return unless attributes["mortgagelender"] == MORTGAGE_LENDER_OPTIONS["other"]

      case attributes["ownershipsch"]
      when 1
        string_or_nil(xml_doc, "Q24aMortgageLender")
      when 2
        string_or_nil(xml_doc, "Q34a")
      when 3
        string_or_nil(xml_doc, "Q41aMortgageLender")
      end
    end

    def mortgage_length(xml_doc, attributes)
      case attributes["ownershipsch"]
      when 1
        unsafe_string_as_integer(xml_doc, "Q24b")
      when 2
        unsafe_string_as_integer(xml_doc, "Q34b")
      when 3
        unsafe_string_as_integer(xml_doc, "Q41b")
      end
    end

    def savings_known(xml_doc)
      case unsafe_string_as_integer(xml_doc, "savingsKnown")
      when 1 # known
        0
      when 2 # unknown
        1
      end
    end

    def still_serving(xml_doc)
      case unsafe_string_as_integer(xml_doc, "LeftArmedF")
      when 4
        4
      when 5, 6
        5
      end
    end

    def income_known(value)
      case value
      when 1 # known
        0
      when 2 # unknown
        1
      end
    end

    def borrowing(xml_doc, attributes)
      case attributes["ownershipsch"]
      when 1
        unsafe_string_as_integer(xml_doc, "Q25Borrowing")
      when 2
        unsafe_string_as_integer(xml_doc, "Q35Borrowing")
      when 3
        unsafe_string_as_integer(xml_doc, "Q42Borrowing")
      end
    end

    def purchase_price(xml_doc, attributes)
      case attributes["ownershipsch"]
      when 1
        safe_string_as_decimal(xml_doc, "Q22PurchasePrice")
      when 2
        safe_string_as_decimal(xml_doc, "Q31PurchasePrice")
      when 3
        safe_string_as_decimal(xml_doc, "Q40PurchasePrice")
      end
    end

    def deposit(xml_doc, attributes)
      case attributes["ownershipsch"]
      when 1
        safe_string_as_decimal(xml_doc, "Q26CashDeposit")
      when 2
        safe_string_as_decimal(xml_doc, "Q36CashDeposit")
      when 3
        safe_string_as_decimal(xml_doc, "Q43CashDeposit")
      end
    end

    def monthly_charges(xml_doc, attributes)
      case attributes["ownershipsch"]
      when 1
        safe_string_as_decimal(xml_doc, "Q29MonthlyCharges")
      when 2
        safe_string_as_decimal(xml_doc, "Q37MonthlyCharges")
      end
    end

    def ownership_from_type(attributes)
      case attributes["type"]
      when 2, 24, 18, 16, 28, 31, 30
        1 # shared ownership
      when 8, 14, 27, 9, 29, 21, 22
        2 # discounted ownership
      when 10, 12
        3 # outright sale
      end
    end

    def other_household_members(xml_doc, attributes)
      hholdcount = safe_string_as_integer(xml_doc, "LiveInOther")
      return hholdcount if hholdcount.present?

      other_people_with_details(xml_doc, attributes)
    end

    def other_people_with_details(xml_doc, attributes)
      number_of_buyers = attributes["jointpur"] == 1 ? 2 : 1
      highest_person_index_with_details = number_of_buyers

      (2..6).each do |person_index|
        age = string_or_nil(xml_doc, "P#{person_index}Age")
        gender = string_or_nil(xml_doc, "P#{person_index}Sex")
        relationship = string_or_nil(xml_doc, "P#{person_index}Rel")
        economic_status = string_or_nil(xml_doc, "P#{person_index}Eco")
        if gender.present? || age.present? || relationship.present? || economic_status.present?
          highest_person_index_with_details = person_index
        end
      end

      highest_person_index_with_details - number_of_buyers
    end

    def household_members(_xml_doc, attributes)
      if attributes["jointpur"] == 2
        attributes["hholdcount"] + 1
      else
        attributes["hholdcount"] + 2
      end
    end

    def parse_postcode(postcode)
      return if postcode.blank?

      UKPostcode.parse(postcode).to_s
    end

    def mortgage_used(xml_doc, attributes)
      mortgageused = unsafe_string_as_integer(xml_doc, "MORTGAGEUSED")
      return mortgageused unless mortgageused == 3

      if attributes["mortgage"].present? || attributes["mortlen"].present? || attributes["extrabor"].present?
        1 # yes
      else
        3 # don't know
      end
    end

    def set_default_values(attributes)
      attributes["armedforcesspouse"] ||= 7
      attributes["hhregres"] ||= 8
      attributes["hhregresstill"] ||= 7 if attributes["hhregres"] == 1
      attributes["disabled"] ||= 3
      attributes["wheel"] ||= 3
      attributes["hb"] ||= 4
      attributes["prevown"] ||= 3
      attributes["savingsnk"] ||= attributes["savings"].present? ? 0 : 1
      attributes["inc1mort"] ||= 3
      if [attributes["pregyrha"], attributes["pregla"], attributes["pregghb"], attributes["pregother"]].all?(&:blank?)
        attributes["pregblank"] = 1
      end
      attributes["pcodenk"] ||= 1
      attributes["prevten"] ||= 0
      attributes["extrabor"] ||= 3 if attributes["mortgageused"] == 1
      attributes["socprevten"] ||= 10 if attributes["ownershipsch"] == 1
      attributes["fromprop"] ||= 0 if attributes["ownershipsch"] == 1
      attributes["mortgagelender"] ||= 0 if attributes["mortgageused"] == 1

      # buyer 1 characteristics
      attributes["age1_known"] ||= 1
      attributes["sex1"] ||= "R"
      attributes["ethnic_group"] ||= 17
      attributes["ethnic"] ||= 17
      attributes["national"] ||= 13
      attributes["ecstat1"] ||= 10
      attributes["income1nk"] ||= attributes["income1"].present? ? 0 : 1

      # buyer 2 characteristics
      if attributes["jointpur"] == 1
        attributes["age2_known"] ||= 1
        attributes["sex2"] ||= "R"
        attributes["ecstat2"] ||= 10
        attributes["income2nk"] ||= attributes["income2"].present? ? 0 : 1
        attributes["relat2"] ||= "R"
        attributes["inc2mort"] ||= 3
        attributes["buy2livein"] ||= 1 unless attributes["ownershipsch"] == 3
      end

      # other household members characteristics
      (2..[attributes["hhmemb"], 6].min).each do |index|
        attributes["age#{index}_known"] ||= 1
        attributes["sex#{index}"] ||= "R"
        attributes["ecstat#{index}"] ||= 10
        attributes["relat#{index}"] ||= "R"
      end
    end

    def missing_answers(sales_log)
      applicable_questions = sales_log.form.subsections.map { |s| s.applicable_questions(sales_log).select { |q| q.enabled?(sales_log) } }.flatten
      applicable_questions.filter { |q| q.unanswered?(sales_log) }.map(&:id) - sales_log.optional_fields
    end
  end
end
