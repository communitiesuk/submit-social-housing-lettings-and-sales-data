class BulkUpload::LettingsLogToCsv
  attr_reader :log, :line_ending, :col_offset, :overrides

  def initialize(log:, line_ending: "\n", col_offset: 1, overrides: {})
    # rubocop:disable Rails/HelperInstanceVariable
    @log = log
    @line_ending = line_ending
    @col_offset = col_offset
    @overrides = overrides
    # rubocop:enable Rails/HelperInstanceVariable
  end

  def row_prefix
    [nil] * col_offset
  end

  def to_csv_row(seed: nil)
    year = log.collection_start_year
    case year
    when 2022, 2023, 2024, 2025, 2026
      to_year_csv_row(year, seed:)
    else
      raise NotImplementedError "No mapping function implemented for year #{year}"
    end
  end

  def to_row
    year = log.collection_start_year
    send("to_#{year}_row")
  rescue NoMethodError
    raise NotImplementedError "No mapping function implemented for year #{year}"
  end

  def default_field_numbers_row(seed: nil)
    year = log.collection_start_year
    default_field_numbers_row_for_year(year, seed:)
  rescue NoMethodError
    raise NotImplementedError "No mapping function implemented for year #{year}"
  end

  def default_field_numbers
    year = log.collection_start_year
    send("default_#{year}_field_numbers")
  rescue NoMethodError
    raise NotImplementedError "No mapping function implemented for year #{year}"
  end

  def to_year_csv_row(year, seed: nil)
    unshuffled_row = send("to_#{year}_row")
    if seed
      row = unshuffled_row.shuffle(random: Random.new(seed))
      (row_prefix + row).flatten.join(",") + line_ending
    else
      (row_prefix + unshuffled_row).flatten.join(",") + line_ending
    end
  end

  def to_2023_row
    to_2022_row + [
      log.needstype,
      log.location&.id,
      log.uprn,
      log.address_line1,
      log.address_line2,
      log.town_or_city,
      log.county,
    ]
  end

  def default_field_numbers_row_for_year(year, seed: nil)
    if seed
      ["Field number"] + send("default_#{year}_field_numbers").shuffle(random: Random.new(seed))
    else
      ["Field number"] + send("default_#{year}_field_numbers")
    end.flatten.join(",") + line_ending
  end

  def default_2022_field_numbers
    (1..134).to_a
  end

  def default_2023_field_numbers
    [5, nil, nil, 15, 16, nil, 13, 40, 41, 42, 43, 46, 52, 56, 60, 64, 68, 72, 76, 47, 53, 57, 61, 65, 69, 73, 77, 51, 55, 59, 63, 67, 71, 75, 50, 54, 58, 62, 66, 70, 74, 78, 48, 49, 79, 81, 82, 123, 124, 122, 120, 102, 103, nil, 83, 84, 85, 86, 87, 88, 104, 109, 107, 108, 106, 100, 101, 105, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 126, 128, 129, 130, 131, 132, 127, 125, 133, 134, 33, 34, 35, 36, 37, 38, nil, 7, 8, 9, 28, 14, 32, 29, 30, 31, 26, 27, 25, 23, 24, nil, 1, 3, 2, 80, nil, 121, 44, 89, 98, 92, 95, 90, 91, 93, 94, 97, 96, 99, 10, 11, 12, 45, 39, 6, 4, 17, 18, 19, 20, 21, 22]
  end

  def default_2024_field_numbers
    (1..130).to_a
  end

  def default_2025_field_numbers
    (1..129).to_a
  end

  def default_2026_field_numbers
    (1..BulkUpload::Lettings::Year2026::CsvParser::FIELDS).to_a
  end

  def to_2026_row
    # TODO: CLDC-4162: Implement when 2026 format is known
    [
      overrides[:organisation_id] || log.owning_organisation&.old_visible_id, # 1
      overrides[:managing_organisation_id] || log.managing_organisation&.old_visible_id,
      log.assigned_to&.email,
      log.needstype,
      log.scheme&.id ? "S#{log.scheme&.id}" : "",
      log.location&.id,
      renewal,
      log.startdate&.day,
      log.startdate&.month,
      log.startdate&.strftime("%y"), # 10

      rent_type,
      log.irproduct_other,
      log.tenancycode,
      log.propcode,
      log.declaration,
      log.rsnvac,
      log.unitletas,
      log.uprn,
      log.address_line1&.tr(",", " "),
      log.address_line2&.tr(",", " "), # 20

      log.town_or_city&.tr(",", " "),
      log.county&.tr(",", " "),
      ((log.postcode_full || "").split(" ") || [""]).first,
      ((log.postcode_full || "").split(" ") || [""]).last,
      log.la,
      log.unittype_gn,
      log.builtype,
      log.wchair,
      log.beds,
      log.voiddate&.day, # 30

      log.voiddate&.month,
      log.voiddate&.strftime("%y"),
      log.mrcdate&.day,
      log.mrcdate&.month,
      log.mrcdate&.strftime("%y"),
      log.sheltered,
      log.joint,
      log.startertenancy,
      log.tenancy,
      log.tenancyother, # 40

      log.tenancylength,
      log.age1 || overrides[:age1],
      log.sexrab1,
      log.ethnic,
      log.nationality_all_group,
      log.ecstat1,
      relat_number(log.relat2),
      log.age2 || overrides[:age2],
      log.sexrab2,
      log.ecstat2, # 50

      relat_number(log.relat3),
      log.age3 || overrides[:age3],
      log.sexrab3,
      log.ecstat3,
      relat_number(log.relat4),
      log.age4 || overrides[:age4],
      log.sexrab4,
      log.ecstat4,
      relat_number(log.relat5),
      log.age5 || overrides[:age5], # 60

      log.sexrab5,
      log.ecstat5,
      relat_number(log.relat6),
      log.age6 || overrides[:age6],
      log.sexrab6,
      log.ecstat6,
      relat_number(log.relat7),
      log.age7 || overrides[:age7],
      log.sexrab7,
      log.ecstat7, # 70

      relat_number(log.relat8),
      log.age8 || overrides[:age8],
      log.sexrab8,
      log.ecstat8,
      log.armedforces,
      log.leftreg,
      log.reservist,
      log.preg_occ,
      log.housingneeds_a,
      log.housingneeds_b, # 80

      log.housingneeds_c,
      log.housingneeds_f,
      log.housingneeds_g,
      log.housingneeds_h,
      overrides[:illness] || log.illness,
      log.illness_type_1,
      log.illness_type_2,
      log.illness_type_3,
      log.illness_type_4,
      log.illness_type_5, # 90

      log.illness_type_6,
      log.illness_type_7,
      log.illness_type_8,
      log.illness_type_9,
      log.illness_type_10,
      log.layear,
      log.waityear,
      log.reason,
      log.reasonother,
      log.prevten, # 100

      homeless,
      previous_postcode_known,
      ((log.ppostcode_full || "").split(" ") || [""]).first,
      ((log.ppostcode_full || "").split(" ") || [""]).last,
      log.prevloc,
      log.reasonpref,
      log.rp_homeless,
      log.rp_insan_unsat,
      log.rp_medwel,
      log.rp_hardship, # 110

      log.rp_dontknow,
      cbl,
      chr,
      cap,
      accessible_register,
      log.owning_organisation.la? ? log.referral_register : nil,
      net_income_known,
      log.incfreq,
      log.earnings,
      log.hb, # 120

      log.benefits,
      log.household_charge,
      log.period,
      log.brent,
      log.scharge,
      log.pscharge,
      log.supcharg,
      log.hbrentshortfall,
      log.tshortfall,

      log.gender_same_as_sex1, # 130
      log.gender_description1,
      log.gender_same_as_sex2,
      log.gender_description2,
      log.gender_same_as_sex3,
      log.gender_description3,
      log.gender_same_as_sex4,
      log.gender_description4,
      log.gender_same_as_sex5,
      log.gender_description5,
      log.gender_same_as_sex6, # 140
      log.gender_description6,
      log.gender_same_as_sex7,
      log.gender_description7,
      log.gender_same_as_sex8,
      log.gender_description8,
      log.owning_organisation.prp? ? log.referral_register : nil,
      log.referral_noms,
      log.referral_org, # 148
    ]
  end

  def to_2025_row
    [
      overrides[:organisation_id] || log.owning_organisation&.old_visible_id, # 1
      overrides[:managing_organisation_id] || log.managing_organisation&.old_visible_id,
      log.assigned_to&.email,
      log.needstype,
      log.scheme&.id ? "S#{log.scheme&.id}" : "",
      log.location&.id,
      renewal,
      log.startdate&.day,
      log.startdate&.month,
      log.startdate&.strftime("%y"), # 10

      rent_type,
      log.irproduct_other,
      log.tenancycode,
      log.propcode,
      log.declaration,
      log.rsnvac,
      log.unitletas,
      log.uprn,
      log.address_line1&.tr(",", " "),
      log.address_line2&.tr(",", " "), # 20

      log.town_or_city&.tr(",", " "),
      log.county&.tr(",", " "),
      ((log.postcode_full || "").split(" ") || [""]).first,
      ((log.postcode_full || "").split(" ") || [""]).last,
      log.la,
      log.unittype_gn,
      log.builtype,
      log.wchair,
      log.beds,
      log.voiddate&.day, # 30

      log.voiddate&.month,
      log.voiddate&.strftime("%y"),
      log.mrcdate&.day,
      log.mrcdate&.month,
      log.mrcdate&.strftime("%y"),
      log.sheltered,
      log.joint,
      log.startertenancy,
      log.tenancy,
      log.tenancyother, # 40

      log.tenancylength,
      log.age1 || overrides[:age1],
      log.sex1,
      log.ethnic,
      log.nationality_all_group,
      log.ecstat1,
      relat_number(log.relat2),
      log.age2 || overrides[:age2],
      log.sex2,
      log.ecstat2, # 50

      relat_number(log.relat3),
      log.age3 || overrides[:age3],
      log.sex3,
      log.ecstat3,
      relat_number(log.relat4),
      log.age4 || overrides[:age4],
      log.sex4,
      log.ecstat4,
      relat_number(log.relat5),
      log.age5 || overrides[:age5], # 60

      log.sex5,
      log.ecstat5,
      relat_number(log.relat6),
      log.age6 || overrides[:age6],
      log.sex6,
      log.ecstat6,
      relat_number(log.relat7),
      log.age7 || overrides[:age7],
      log.sex7,
      log.ecstat7, # 70

      relat_number(log.relat8),
      log.age8 || overrides[:age8],
      log.sex8,
      log.ecstat8,
      log.armedforces,
      log.leftreg,
      log.reservist,
      log.preg_occ,
      log.housingneeds_a,
      log.housingneeds_b, # 80

      log.housingneeds_c,
      log.housingneeds_f,
      log.housingneeds_g,
      log.housingneeds_h,
      overrides[:illness] || log.illness,
      log.illness_type_1,
      log.illness_type_2,
      log.illness_type_3,
      log.illness_type_4,
      log.illness_type_5, # 90

      log.illness_type_6,
      log.illness_type_7,
      log.illness_type_8,
      log.illness_type_9,
      log.illness_type_10,
      log.layear,
      log.waityear,
      log.reason,
      log.reasonother,
      log.prevten, # 100

      homeless,
      previous_postcode_known,
      ((log.ppostcode_full || "").split(" ") || [""]).first,
      ((log.ppostcode_full || "").split(" ") || [""]).last,
      log.prevloc,
      log.reasonpref,
      log.rp_homeless,
      log.rp_insan_unsat,
      log.rp_medwel,
      log.rp_hardship, # 110

      log.rp_dontknow,
      cbl,
      chr,
      cap,
      accessible_register,
      log.referral,
      net_income_known,
      log.incfreq,
      log.earnings,
      log.hb, # 120

      log.benefits,
      log.household_charge,
      log.period,
      log.brent,
      log.scharge,
      log.pscharge,
      log.supcharg,
      log.hbrentshortfall,
      log.tshortfall, # 129
    ]
  end

  def to_2024_row
    [
      overrides[:organisation_id] || log.owning_organisation&.old_visible_id, # 1
      overrides[:managing_organisation_id] || log.managing_organisation&.old_visible_id,
      log.assigned_to&.email,
      log.needstype,
      log.scheme&.id ? "S#{log.scheme&.id}" : "",
      log.location&.id,
      renewal,
      log.startdate&.day,
      log.startdate&.month,
      log.startdate&.strftime("%y"), # 10

      rent_type,
      log.irproduct_other,
      log.tenancycode,
      log.propcode,
      log.declaration,
      log.uprn,
      log.address_line1&.tr(",", " "),
      log.address_line2&.tr(",", " "),
      log.town_or_city&.tr(",", " "),
      log.county&.tr(",", " "), # 20

      ((log.postcode_full || "").split(" ") || [""]).first,
      ((log.postcode_full || "").split(" ") || [""]).last,
      log.la,
      log.rsnvac,
      log.unitletas,
      log.unittype_gn,
      log.builtype,
      log.wchair,
      log.beds,
      log.voiddate&.day, # 30

      log.voiddate&.month,
      log.voiddate&.strftime("%y"),
      log.mrcdate&.day,
      log.mrcdate&.month,
      log.mrcdate&.strftime("%y"),
      log.joint,
      log.startertenancy,
      log.tenancy,
      log.tenancyother,
      log.tenancylength, # 40

      log.sheltered,
      log.age1 || overrides[:age1],
      log.sex1,
      log.ethnic,
      log.nationality_all_group,
      log.ecstat1,
      log.relat2,
      log.age2 || overrides[:age2],
      log.sex2,
      log.ecstat2, # 50

      log.relat3,
      log.age3 || overrides[:age3],
      log.sex3,
      log.ecstat3,
      log.relat4,
      log.age4 || overrides[:age4],
      log.sex4,
      log.ecstat4,
      log.relat5,
      log.age5 || overrides[:age5], # 60

      log.sex5,
      log.ecstat5,
      log.relat6,
      log.age6 || overrides[:age6],
      log.sex6,
      log.ecstat6,
      log.relat7,
      log.age7 || overrides[:age7],
      log.sex7,
      log.ecstat7, # 70

      log.relat8,
      log.age8 || overrides[:age8],
      log.sex8,
      log.ecstat8,
      log.armedforces,
      log.leftreg,
      log.reservist,
      log.preg_occ,
      log.housingneeds_a,
      log.housingneeds_b, # 80

      log.housingneeds_c,
      log.housingneeds_f,
      log.housingneeds_g,
      log.housingneeds_h,
      overrides[:illness] || log.illness,
      log.illness_type_1,
      log.illness_type_2,
      log.illness_type_3,
      log.illness_type_4,
      log.illness_type_5, # 90

      log.illness_type_6,
      log.illness_type_7,
      log.illness_type_8,
      log.illness_type_9,
      log.illness_type_10,
      log.layear,
      log.waityear,
      log.reason,
      log.reasonother,
      log.prevten, # 100

      homeless,
      previous_postcode_known,
      ((log.ppostcode_full || "").split(" ") || [""]).first,
      ((log.ppostcode_full || "").split(" ") || [""]).last,
      log.prevloc,
      log.reasonpref,
      log.rp_homeless,
      log.rp_insan_unsat,
      log.rp_medwel,
      log.rp_hardship, # 110

      log.rp_dontknow,
      cbl,
      chr,
      cap,
      accessible_register,
      log.referral,
      net_income_known,
      log.incfreq,
      log.earnings,
      log.hb, # 120

      log.benefits,
      log.household_charge,
      log.period,
      log.chcharge,
      log.brent,
      log.scharge,
      log.pscharge,
      log.supcharg,
      log.hbrentshortfall,
      log.tshortfall, # 130
    ]
  end

  def to_2022_row
    [
      log.renttype, # 1
      nil,
      nil,
      log.scheme&.old_visible_id,
      log.location&.old_visible_id,
      nil,
      log.tenancycode,
      log.startertenancy,
      log.tenancy,
      log.tenancyother, # 10
      log.tenancylength,
      log.age1 || overrides[:age1],
      log.age2 || overrides[:age2],
      log.age3 || overrides[:age3],
      log.age4 || overrides[:age4],
      log.age5 || overrides[:age5],
      log.age6 || overrides[:age6],
      log.age7 || overrides[:age7],
      log.age8 || overrides[:age8],

      log.sex1, # 20
      log.sex2,
      log.sex3,
      log.sex4,
      log.sex5,
      log.sex6,
      log.sex7,
      log.sex8,

      log.relat2,
      log.relat3,
      log.relat4, # 30
      log.relat5,
      log.relat6,
      log.relat7,
      log.relat8,

      log.ecstat1,
      log.ecstat2,
      log.ecstat3,
      log.ecstat4,
      log.ecstat5,
      log.ecstat6, # 40
      log.ecstat7,
      log.ecstat8,

      log.ethnic,
      log.national,
      log.armedforces,
      log.reservist,
      log.preg_occ,
      log.hb,
      log.benefits,
      log.earnings, # 50
      net_income_known,
      log.reason,
      log.reasonother,
      nil,
      log.housingneeds_a,
      log.housingneeds_b,
      log.housingneeds_c,
      log.housingneeds_f,
      log.housingneeds_g,
      log.housingneeds_h, # 60
      log.prevten,
      log.prevloc,
      ((log.ppostcode_full || "").split(" ") || [""]).first,
      ((log.ppostcode_full || "").split(" ") || [""]).last,
      previous_postcode_known,
      log.layear,
      log.waityear,
      homeless,
      log.reasonpref,
      log.rp_homeless, # 70
      log.rp_insan_unsat,
      log.rp_medwel,
      log.rp_hardship,
      log.rp_dontknow,
      cbl,
      chr,
      cap,
      log.referral,
      log.period,

      log.brent, # 80
      log.scharge,
      log.pscharge,
      log.supcharg,
      log.tcharge,
      log.chcharge,
      log.household_charge,
      log.hbrentshortfall,
      log.tshortfall,
      log.voiddate&.day,

      log.voiddate&.month, # 90
      log.voiddate&.strftime("%y"),
      log.mrcdate&.day,
      log.mrcdate&.month,
      log.mrcdate&.strftime("%y"),
      nil,
      log.startdate&.day,
      log.startdate&.month,
      log.startdate&.strftime("%y"),
      log.offered,

      log.propcode, # 100
      log.beds,
      log.unittype_gn,
      log.builtype,
      log.wchair,
      log.unitletas,
      log.rsnvac,
      log.la,
      ((log.postcode_full || "").split(" ") || [""]).first,
      ((log.postcode_full || "").split(" ") || [""]).last,

      nil, # 110
      log.owning_organisation&.old_visible_id,
      log.assigned_to&.email,
      log.managing_organisation&.old_visible_id,
      leftreg,
      nil,
      log.incfreq,
      log.sheltered,
      overrides[:illness] || log.illness,
      log.illness_type_1,

      log.illness_type_2, # 120
      log.illness_type_3,
      log.illness_type_4,
      log.illness_type_5,
      log.illness_type_6,
      log.illness_type_7,
      log.illness_type_8,
      log.illness_type_9,
      log.illness_type_10,
      london_affordable_rent,

      intermediate_rent_type, # 130
      log.irproduct_other,
      log.declaration,
      log.joint,
      renewal,
    ]
  end

  def custom_field_numbers_row(seed: nil, field_numbers: nil)
    if seed
      ["Field number"] + field_numbers.shuffle(random: Random.new(seed))
    else
      ["Field number"] + field_numbers
    end.flatten.join(",") + line_ending
  end

  def to_custom_csv_row(seed: nil, field_values: nil)
    row = seed ? field_values.shuffle(random: Random.new(seed)) : field_values
    (row_prefix + row).flatten.join(",") + line_ending
  end

private

  def renewal
    checkbox_value(log.renewal)
  end

  def london_affordable_rent
    case log.renttype
    when LettingsLog::RENT_TYPE[:london_affordable_rent]
      1
    end
  end

  def intermediate_rent_type
    case log.renttype
    when LettingsLog::RENT_TYPE[:rent_to_buy]
      1
    when LettingsLog::RENT_TYPE[:london_living_rent]
      2
    when LettingsLog::RENT_TYPE[:other_intermediate_rent_product]
      3
    end
  end

  def rent_type
    LettingsLog::RENTTYPE_DETAIL_MAPPING[log.rent_type]
  end

  def leftreg
    case log.leftreg
    when 3
      3
    when 1
      4
    when 2
      5
    when 0
      6
    end
  end

  def net_income_known
    case log.net_income_known
    when 0
      1
    when 1
      2
    when 2
      4
    end
  end

  def previous_postcode_known
    checkbox_value(log.ppcodenk)
  end

  def homeless
    case log.homeless
    when 1
      1
    when 11
      12
    end
  end

  def cbl
    checkbox_value(log.cbl)
  end

  def chr
    checkbox_value(log.chr)
  end

  def cap
    checkbox_value(log.cap)
  end

  def accessible_register
    checkbox_value(log.accessible_register)
  end

  def checkbox_value(field)
    case field
    when 0
      2
    when 1
      1
    end
  end

  def hhregres
    if log.hhregres == 1
      log.hhregresstill
    else
      log.hhregres
    end
  end

  def relat_number(value)
    case value
    when "P"
      1
    when "R"
      3
    when "C", "X"
      2
    end
  end
end
