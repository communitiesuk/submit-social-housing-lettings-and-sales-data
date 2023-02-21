module Imports
  class SalesLogsImportService < ImportService
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
      attributes = {}

      previous_status = meta_field_value(xml_doc, "status")

      # Required fields for status complete or logic to work
      # Note: order matters when we derive from previous values (attributes parameter)

      attributes["saledate"] = compose_date(xml_doc, "DAY", "MONTH", "YEAR")
      attributes["owning_organisation_id"] = find_organisation_id(xml_doc, "OWNINGORGID")
      attributes["type"] = unsafe_string_as_integer(xml_doc, "DERSALETYPE")
      attributes["old_id"] = meta_field_value(xml_doc, "document-id")
      attributes["created_at"] = Time.zone.parse(meta_field_value(xml_doc, "created-date"))
      attributes["updated_at"] = Time.zone.parse(meta_field_value(xml_doc, "modified-date"))
      attributes["purchid"] = string_or_nil(xml_doc, "PURCHASERCODE")
      attributes["ownershipsch"] = unsafe_string_as_integer(xml_doc, "OWNERSHIP")
      attributes["othtype"] = string_or_nil(xml_doc, "Q38OTHERSALE")
      attributes["jointmore"] = unsafe_string_as_integer(xml_doc, "JOINTMORE")
      attributes["jointpur"] = unsafe_string_as_integer(xml_doc, "JOINT")
      attributes["beds"] = safe_string_as_integer(xml_doc, "Q11BEDROOMS")
      attributes["companybuy"] = unsafe_string_as_integer(xml_doc, "COMPANY")
      attributes["hhmemb"] = safe_string_as_integer(xml_doc, "HHMEMB")
      (1..6).each do |index|
        attributes["age#{index}"] = safe_string_as_integer(xml_doc, "P#{index}AGE")
        attributes["sex#{index}"] = sex(xml_doc, index)
        attributes["ecstat#{index}"] = unsafe_string_as_integer(xml_doc, "P#{index}ECO")
        attributes["age#{index}_known"] = age_known(xml_doc, index, attributes["hhmemb"], attributes["age#{index}"])
      end
      (2..6).each do |index|
        attributes["relat#{index}"] = relat(xml_doc, index)
        attributes["details_known_#{index}"] = details_known(index, attributes)
      end

      attributes["national"] = unsafe_string_as_integer(xml_doc, "P1NAT")
      attributes["othernational"] = nil
      attributes["ethnic"] = unsafe_string_as_integer(xml_doc, "P1ETH")
      attributes["ethnic_group"] = ethnic_group(attributes["ethnic"]) # check numbers
      attributes["buy1livein"] = unsafe_string_as_integer(xml_doc, "LIVEINBUYER1")
      attributes["buylivein"] = unsafe_string_as_integer(xml_doc, "LIVEINBUYER")
      attributes["builtype"] = unsafe_string_as_integer(xml_doc, "Q13BUILDINGTYPE")
      attributes["proptype"] = unsafe_string_as_integer(xml_doc, "Q12PROPERTYTYPE")
      attributes["noint"] = safe_string_as_integer(xml_doc, "NOINT")
      attributes["buy2livein"] = unsafe_string_as_integer(xml_doc, "LIVEINBUYER2")
      attributes["privacynotice"] = 1 if string_or_nil(xml_doc, "QDP") == "Yes"
      attributes["wheel"] = unsafe_string_as_integer(xml_doc, "Q10WHEELCHAIR")
      attributes["hholdcount"] = safe_string_as_integer(xml_doc, "LIVEINOTHER")
      attributes["la"] = string_or_nil(xml_doc, "Q14ONSLACODE")
      attributes["income1"] = safe_string_as_integer(xml_doc, "Q2PERSON1INCOME") # should this be decimal?
      attributes["income1nk"] = 0 if attributes["income1"].present? # known if given? there's P1IncKnown in the form should use that instead?
      attributes["inc1mort"] = unsafe_string_as_integer(xml_doc, "Q2PERSON1MORTGAGE")
      attributes["income2"] = safe_string_as_integer(xml_doc, "Q2PERSON2INCOME") # should this be decimal?
      attributes["income2nk"] = 0 if attributes["income2"].present? # known if given?
      attributes["savings"] = safe_string_as_integer(xml_doc, "Q3SAVINGS")
      attributes["savingsnk"] = savings_known(xml_doc) # 0 -> known, 1 - not known from the sales xml form, does this actually exist?
      attributes["prevown"] = unsafe_string_as_integer(xml_doc, "Q4PREVOWNEDPROPERTY")
      attributes["mortgage"] = safe_string_as_decimal(xml_doc, "CALCMORT")
      attributes["inc2mort"] = unsafe_string_as_integer(xml_doc, "Q2PERSON2MORTAPPLICATION")
      attributes["hb"] = unsafe_string_as_integer(xml_doc, "Q2A")
      attributes["frombeds"] = safe_string_as_integer(xml_doc, "Q20BEDROOMS")
      attributes["staircase"] = unsafe_string_as_integer(xml_doc, "Q17ASTAIRCASE")
      attributes["stairbought"] = safe_string_as_integer(xml_doc, "PERCENTBOUGHT") # ?
      attributes["stairowned"] = safe_string_as_integer(xml_doc, "PERCENTOWNS") # ?
      attributes["mrent"] = safe_string_as_decimal(xml_doc, "Q28MONTHLYRENT")
      attributes["exdate"] = compose_date(xml_doc, "EXDAY", "EXMONTH", "EXYEAR")
      attributes["exday"] = safe_string_as_integer(xml_doc, "EXDAY")
      attributes["exmonth"] = safe_string_as_integer(xml_doc, "EXMONTH")
      attributes["exyear"] = safe_string_as_integer(xml_doc, "EXYEAR")
      attributes["resale"] = unsafe_string_as_integer(xml_doc, "Q17RESALE")
      attributes["deposit"] = safe_string_as_decimal(xml_doc, "Q26CASHDEPOSIT")
      attributes["cashdis"] = safe_string_as_decimal(xml_doc, "Q27SOCIALHOMEBUY")
      attributes["disabled"] = unsafe_string_as_integer(xml_doc, "DISABILITY")
      attributes["lanomagr"] = unsafe_string_as_integer(xml_doc, "Q19REHOUSED")
      attributes["value"] = safe_string_as_decimal(xml_doc, "Q22PURCHASEPRICE")
      attributes["equity"] = safe_string_as_decimal(xml_doc, "Q23EQUITY")
      attributes["discount"] = safe_string_as_decimal(xml_doc, "Q33DISCOUNT")
      attributes["grant"] = safe_string_as_decimal(xml_doc, "Q32REDUCTIONS")
      attributes["pregyrha"] = 1 if string_or_nil(xml_doc, "PREGYRHA") == "Yes"
      attributes["pregla"] = 1 if string_or_nil(xml_doc, "PREGLA") == "Yes"
      attributes["pregghb"] = 1 if string_or_nil(xml_doc, "PREGHBA") == "Yes" # PREGHBA?
      attributes["pregother"] = 1 if string_or_nil(xml_doc, "PREGOTHER") == "Yes"
      attributes["ppostcode_full"] = compose_postcode(xml_doc, "PPOSTC1", "PPOSTC2")
      attributes["prevloc"] = string_or_nil(xml_doc, "Q7ONSLACODE")
      # attributes["is_previous_la_inferred"] = nil
      attributes["ppcodenk"] = previous_postcode_known(xml_doc, attributes["ppostcode_full"], attributes["prevloc"]) # Q7UNKNOWNPOSTCODE check mapping
      attributes["ppostc1"] = string_or_nil(xml_doc, "PPOSTC1")
      attributes["ppostc2"] = string_or_nil(xml_doc, "PPOSTC2")
      attributes["previous_la_known"] = nil
      attributes["hhregres"] = unsafe_string_as_integer(xml_doc, "ARMEDF")
      attributes["hhregresstill"] = 7 # are we not collecting this? 7 == don't know
      attributes["proplen"] = safe_string_as_integer(xml_doc, "Q30A")
      attributes["mscharge"] = safe_string_as_decimal(xml_doc, "Q29MONTHLYCHARGES")
      attributes["mscharge_known"] = 1 if attributes["mscharge"].present?
      attributes["prevten"] = unsafe_string_as_integer(xml_doc, "Q6PREVTENURE")
      attributes["mortgageused"] = unsafe_string_as_integer(xml_doc, "MORTGAGEUSED")
      attributes["wchair"] = unsafe_string_as_integer(xml_doc, "Q15WHEELCHAIR")
      attributes["armedforcesspouse"] = unsafe_string_as_integer(xml_doc, "ARMEDFORCESSPOUSE")
      attributes["hodate"] = compose_date(xml_doc, "HODAY", "HOMONTH", "HOYEAR")
      attributes["hoday"] = safe_string_as_integer(xml_doc, "HODAY")
      attributes["homonth"] = safe_string_as_integer(xml_doc, "HOMONTH")
      attributes["hoyear"] = safe_string_as_integer(xml_doc, "HOYEAR")
      attributes["fromprop"] = unsafe_string_as_integer(xml_doc, "Q21PROPERTYTYPE")
      attributes["socprevten"] = nil # ?
      attributes["mortgagelender"] = mortgage_lender(xml_doc, attributes) # there's mortgagelender 1/2/3? Q24AMORTGAGELENDER Q34AMORTGAGELENDER Q41AMORTGAGELENDER
      attributes["mortgagelenderother"] = nil # Q24AMORTGAGELENDEROTHER Q34AMORTGAGELENDEROTHER Q41AMORTGAGELENDEROTHER
      attributes["mortlen"] = mortgage_length(xml_doc, attributes) # there's mortlen 1/2/3? Q24B Q34B Q41B
      attributes["extrabor"] = unsafe_string_as_integer(xml_doc, "Q25BORROWING")
      # attributes["totadult"] = safe_string_as_integer(xml_doc, "TOTADULT") # these would get overridden anyways
      # attributes["totchild"] = safe_string_as_integer(xml_doc, "TOTCHILD") # these would get overridden anyways
      attributes["hhtype"] = unsafe_string_as_integer(xml_doc, "HHTYPE")
      attributes["pcode1"] = string_or_nil(xml_doc, "PCODE1")
      attributes["pcode2"] = string_or_nil(xml_doc, "PCODE2")
      attributes["postcode_full"] = compose_postcode(xml_doc, "PCODE1", "PCODE2")
      attributes["pcodenk"] = postcode_known(attributes)
      # attributes["is_la_inferred"] = nil
      attributes["bulk_upload_id"] = nil
      attributes["saledate_check"] = nil
      attributes["ethnic_group2"] = nil
      attributes["ethnicbuy2"] = nil
      attributes["prevshared"] = nil
      attributes["staircasesale"] = nil
      attributes["soctenant"] = soctenant(attributes)

      # Required for our form invalidated questions (not present in import)
      attributes["previous_la_known"] = attributes["prevloc"].nil? ? 0 : 1
      attributes["is_la_inferred"] = attributes["postcode_full"].present?
      attributes["la_known"] = attributes["la"].nil? ? 0 : 1

      # Sets the log creator
      owner_id = meta_field_value(xml_doc, "owner-user-id").strip
      if owner_id.present?
        user = LegacyUser.find_by(old_user_id: owner_id)&.user
        @logger.warn "Missing user! We expected to find a legacy user with old_user_id #{owner_id}" unless user

        attributes["created_by"] = user
      end

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

    def rescue_validation_or_raise(sales_log, _attributes, _previous_status, exception)
      @logger.error("Log #{sales_log.old_id}: Failed to import")
      raise exception
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
         hodate_check]
    end

    def check_status_completed(sales_log, previous_status)
      if previous_status.include?("submitted") && sales_log.status != "completed"
        @logger.warn "sales log #{sales_log.id} is not completed"
        @logger.warn "sales log with old id:#{sales_log.old_id} is incomplete but status should be complete"
        @logs_with_discrepancies << sales_log.old_id
      end
    end

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
      previous_postcode_known = string_or_nil(xml_doc, "Q7UNKNOWNPOSTCODE")
      if previous_postcode_known == "If postcode not known tick" || (previous_postcode.nil? && prevloc.present?)
        1
      elsif previous_postcode.nil?
        nil
      else
        0
      end
    end

    def postcode_known(attributes)
      return 0 if attributes["postcode_full"].present? # known if given
      return 1 if attributes["la"].present? # unknown if la is given
    end

    def sex(xml_doc, index)
      sex = string_or_nil(xml_doc, "P#{index}SEX")
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
      relat = string_or_nil(xml_doc, "P#{index}REL")
      case relat
      when "Child"
        "C"
      when "Partner"
        "P"
      when "Other", "Non-binary"
        "X"
      when "Buyer prefers not to say"
        "R"
      end
    end

    def age_known(_xml_doc, index, hhmemb, age)
      return nil if hhmemb.present? && index > hhmemb

      return 0 if age.present?
    end

    def details_known(index, attributes)
      return nil if attributes["hhmemb"].nil? || index > attributes["hhmemb"]
      return nil if attributes["jointpur"] == 1 && index == 2

      if attributes["age#{index}_known"] == 1 &&
          attributes["sex#{index}"] == "R" &&
          attributes["relat#{index}"] == "R" &&
          attributes["ecstat#{index}"] == 10
        2 # No
      else
        1 # Yes
      end
    end

    def mortgage_lender(xml_doc, attributes)
      case attributes["ownershipsch"]
      when 1
        unsafe_string_as_integer(xml_doc, "Q24AMORTGAGELENDER")
      when 2
        unsafe_string_as_integer(xml_doc, "Q34AMORTGAGELENDER")
      when 3
        unsafe_string_as_integer(xml_doc, "Q41AMORTGAGELENDER")
      end
    end

    def mortgage_length(xml_doc, attributes)
      case attributes["ownershipsch"]
      when 1
        unsafe_string_as_integer(xml_doc, "Q24B")
      when 2
        unsafe_string_as_integer(xml_doc, "Q34B")
      when 3
        unsafe_string_as_integer(xml_doc, "Q41B")
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

    def soctenant(attributes)
      return nil unless attributes["ownershipsch"] == 1

      if attributes["frombeds"].blank? && attributes["fromprop"].blank? && attributes["socprevten"].blank?
        2
      else
        1
      end
      # NO (2) if FROMBEDS, FROMPROP and socprevten are blank, and YES(1) if they are completed
    end
  end
end
