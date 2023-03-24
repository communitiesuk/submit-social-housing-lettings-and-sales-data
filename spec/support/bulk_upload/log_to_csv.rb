class BulkUpload::LogToCsv
  attr_reader :log, :line_ending, :col_offset, :overrides

  def initialize(log:, line_ending: "\n", col_offset: 1, overrides: {})
    @log = log
    @line_ending = line_ending
    @col_offset = col_offset
    @overrides = overrides
  end

  def row_prefix
    [nil] * col_offset
  end

  def to_2022_csv_row
    (row_prefix + to_2022_row).flatten.join(",") + line_ending
  end

  def to_2023_csv_row(seed: nil)
    if seed
      row = to_2023_row.shuffle(random: Random.new(seed))
      (row_prefix + row).flatten.join(",") + line_ending
    else
      (row_prefix + to_2023_row).flatten.join(",") + line_ending
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

  def default_2023_field_numbers_row(seed: nil)
    if seed
      ["Bulk upload field number"] + default_2023_field_numbers.shuffle(random: Random.new(seed))
    else
      ["Bulk upload field number"] + default_2023_field_numbers
    end.flatten.join(",") + line_ending
  end

  def default_2023_field_numbers
    [5, nil, nil, 15, 16, nil, 13, 40, 41, 42, 43, 46, 52, 56, 60, 64, 68, 72, 76, 47, 53, 57, 61, 65, 69, 73, 77, 51, 55, 59, 63, 67, 71, 75, 50, 54, 58, 62, 66, 70, 74, 78, 48, 49, 79, 81, 82, 123, 124, 122, 120, 102, 103, nil, 83, 84, 85, 86, 87, 88, 104, 109, 107, 108, 106, 100, 101, 105, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 126, 128, 129, 130, 131, 132, 127, 125, 133, 134, 33, 34, 35, 36, 37, 38, nil, 7, 8, 9, 28, 14, 32, 29, 30, 31, 26, 27, 25, 23, 24, nil, 1, 3, 2, 80, nil, 121, 44, 89, 98, 92, 95, 90, 91, 93, 94, 97, 96, 99, 10, 11, 12, 45, 39, 6, 4, 17, 18, 19, 20, 21, 22]
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
      nil,
      log.reasonother,
      nil,
      nil,
      nil,
      nil,
      nil,
      nil,
      nil, # 60
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
      nil,
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

private

  def renewal
    checkbox_value(log.renewal)
  end

  def london_affordable_rent
    case log.renttype
    when Imports::LettingsLogsImportService::RENT_TYPE[:london_affordable_rent]
      1
    end
  end

  def intermediate_rent_type
    case log.renttype
    when Imports::LettingsLogsImportService::RENT_TYPE[:rent_to_buy]
      1
    when Imports::LettingsLogsImportService::RENT_TYPE[:london_living_rent]
      2
    when Imports::LettingsLogsImportService::RENT_TYPE[:other_intermediate_rent_product]
      3
    end
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

  def checkbox_value(field)
    case field
    when 0
      2
    when 1
      1
    end
  end
end
