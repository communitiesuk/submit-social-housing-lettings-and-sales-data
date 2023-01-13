module DerivedVariables::SalesLogVariables
  def set_derived_fields!
    self.ethnic = 17 if ethnic_refused?
    if exdate.present?
      self.exday = exdate.day
      self.exmonth = exdate.month
      self.exyear = exdate.year
    end
    if hodate.present?
      self.hoday = hodate.day
      self.homonth = hodate.month
      self.hoyear = hodate.year
    end
    self.deposit = value if outright_sale? && mortgage_not_used?
    if mscharge_known.present? && mscharge_known.zero?
      self.mscharge = 0
    end
    self.pcode1, self.pcode2 = postcode_full.split(" ") if postcode_full.present?
    self.totchild = total_child
    self.totadult = total_adult + total_elder
    self.hhmemb = totchild + totadult
    self.hhtype = household_type
  end

private

  def total_elder
    ages = [age1, age2, age3, age4, age5, age6]
    ages.count { |x| !x.nil? && x >= 60 }
  end

  def total_child
    relationships = [relat2, relat3, relat4, relat5, relat6]
    relationships.count("C")
  end

  def total_adult
    total = !age1.nil? && age1 >= 16 && age1 < 60 ? 1 : 0
    total + (2..6).count do |i|
      age = public_send("age#{i}")
      relat = public_send("relat#{i}")
      !age.nil? && ((age >= 16 && age < 18 && %w[P X].include?(relat)) || age >= 18 && age < 60)
    end
  end

  def household_type
    return unless total_elder && total_adult && totchild

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
    total_elder.zero? && total_adult >= 2 && totchild >= 1
  end

  def one_adult_with_at_least_one_child?
    total_elder.zero? && total_adult == 1 && totchild >= 1
  end

  def only_two_adults?
    total_elder.zero? && total_adult == 2 && totchild.zero?
  end

  def only_one_adult?
    total_elder.zero? && total_adult == 1 && totchild.zero?
  end

  def two_adults_including_elders?
    (total_elder + total_adult) == 2 && total_elder >= 1
  end

  def only_one_elder?
    total_elder == 1 && total_adult.zero? && totchild.zero?
  end
end
