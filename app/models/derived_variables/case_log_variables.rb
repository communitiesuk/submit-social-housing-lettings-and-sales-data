module DerivedVariables::CaseLogVariables
  RENT_TYPE_MAPPING = { 0 => 1, 1 => 2, 2 => 2, 3 => 3, 4 => 3, 5 => 3 }.freeze

  def set_derived_fields!
    # TODO: Remove once we support supported housing logs
    self.needstype = 1 unless needstype
    if rsnvac.present?
      self.newprop = has_first_let_vacancy_reason? ? 1 : 2
    end
    self.incref = 1 if net_income_refused?
    self.renttype = RENT_TYPE_MAPPING[rent_type]
    self.lettype = get_lettype
    self.totchild = get_totchild
    self.totelder = get_totelder
    self.totadult = get_totadult
    self.refused = get_refused
    self.ethnic = 17 if ethnic_refused?
    if %i[brent scharge pscharge supcharg].any? { |f| public_send(f).present? }
      self.brent ||= 0
      self.scharge ||= 0
      self.pscharge ||= 0
      self.supcharg ||= 0
      self.tcharge = brent.to_f + scharge.to_f + pscharge.to_f + supcharg.to_f
    end
    if period.present?
      self.wrent = weekly_value(brent) if brent.present?
      self.wscharge = weekly_value(scharge) if scharge.present?
      self.wpschrge = weekly_value(pscharge) if pscharge.present?
      self.wsupchrg = weekly_value(supcharg) if supcharg.present?
      self.wtcharge = weekly_value(tcharge) if tcharge.present?
      if is_supported_housing? && chcharge.present?
        self.wchchrg = weekly_value(chcharge)
      end
    end
    self.has_benefits = get_has_benefits
    self.tshortfall_known = 0 if tshortfall
    self.wtshortfall = if tshortfall && receives_housing_related_benefits?
                         weekly_value(tshortfall)
                       end
    self.nocharge = household_charge&.zero? ? 1 : 0
    self.housingneeds = get_housingneeds
    if is_renewal?
      self.underoccupation_benefitcap = 2 if collection_start_year == 2021
      self.homeless = 1
      self.referral = 0
      self.waityear = 2
      if is_general_needs?
        # fixed term
        self.prevten = 32 if managing_organisation.provider_type == "PRP"
        self.prevten = 30 if managing_organisation.provider_type == "LA"
      end
    end

    child_under_16_constraints!

    self.hhtype = household_type
    self.new_old = new_or_existing_tenant
    self.vacdays = property_vacant_days
  end

private

  def get_totelder
    ages = [age1, age2, age3, age4, age5, age6, age7, age8]
    ages.count { |x| !x.nil? && x >= 60 }
  end

  def get_totchild
    relationships = [relat2, relat3, relat4, relat5, relat6, relat7, relat8]
    relationships.count("C")
  end

  def get_totadult
    total = !age1.nil? && age1 >= 16 && age1 < 60 ? 1 : 0
    total + (2..8).count do |i|
      age = public_send("age#{i}")
      relat = public_send("relat#{i}")
      !age.nil? && ((age >= 16 && age < 18 && %w[P X].include?(relat)) || age >= 18 && age < 60)
    end
  end

  def get_refused
    return 1 if age_refused? || sex_refused? || relat_refused? || ecstat_refused?

    0
  end

  def child_under_16_constraints!
    (2..8).each do |idx|
      if age_under_16?(idx)
        self["ecstat#{idx}"] = 9
      elsif public_send("ecstat#{idx}") == 9 && age_known?(idx)
        self["ecstat#{idx}"] = nil
      end
    end
  end

  def household_type
    return unless totelder && totadult && totchild

    if only_one_elder?
      1
    elsif two_adults_including_elders?
      2
    elsif only_one_adult?
      3
    elsif only_two_adults?
      4
    elsif one_adult_with_at_least_one_child?
      5
    elsif two_adults_with_at_least_one_child?
      6
    else
      9
    end
  end

  def two_adults_with_at_least_one_child?
    totelder.zero? && totadult >= 2 && totchild >= 1
  end

  def one_adult_with_at_least_one_child?
    totelder.zero? && totadult == 1 && totchild >= 1
  end

  def only_two_adults?
    totelder.zero? && totadult == 2 && totchild.zero?
  end

  def only_one_adult?
    totelder.zero? && totadult == 1 && totchild.zero?
  end

  def two_adults_including_elders?
    (totelder + totadult) == 2 && totelder >= 1
  end

  def only_one_elder?
    totelder == 1 && totadult.zero? && totchild.zero?
  end

  def new_or_existing_tenant
    return unless startdate

    referral_within_sector = [1, 10]
    previous_social_tenancies = if collection_start_year <= 2021
                                  [6, 8, 30, 31, 32, 33]
                                else
                                  [6, 30, 31, 32, 33, 34, 35]
                                end

    if previous_social_tenancies.include?(prevten) || referral_within_sector.include?(referral)
      2 # Tenant existing in social housing sector
    else
      1 # Tenant new to social housing sector
    end
  end

  def property_vacant_days
    return unless startdate

    if mrcdate.present?
      (startdate - mrcdate).to_i / 1.day
    elsif voiddate.present?
      (startdate - voiddate).to_i / 1.day
    end
  end
end
