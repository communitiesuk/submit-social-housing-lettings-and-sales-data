class BulkUpload::Lettings::RowParser
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :bulk_upload

  attribute :field_1, :integer
  attribute :field_2
  attribute :field_3
  attribute :field_4, :integer
  attribute :field_5, :integer
  attribute :field_6
  attribute :field_7, :string
  attribute :field_8, :integer
  attribute :field_9, :integer
  attribute :field_10, :string
  attribute :field_11, :integer
  attribute :field_12, :string
  attribute :field_13, :string
  attribute :field_14, :string
  attribute :field_15, :string
  attribute :field_16, :string
  attribute :field_17, :string
  attribute :field_18, :string
  attribute :field_19, :string
  attribute :field_20, :string
  attribute :field_21, :string
  attribute :field_22, :string
  attribute :field_23, :string
  attribute :field_24, :string
  attribute :field_25, :string
  attribute :field_26, :string
  attribute :field_27, :string
  attribute :field_28, :string
  attribute :field_29, :string
  attribute :field_30, :string
  attribute :field_31, :string
  attribute :field_32, :string
  attribute :field_33, :string
  attribute :field_34, :string
  attribute :field_35, :integer
  attribute :field_36, :integer
  attribute :field_37, :integer
  attribute :field_38, :integer
  attribute :field_39, :integer
  attribute :field_40, :integer
  attribute :field_41, :integer
  attribute :field_42, :integer
  attribute :field_43, :integer
  attribute :field_44, :integer
  attribute :field_45, :integer
  attribute :field_46, :integer
  attribute :field_47, :integer
  attribute :field_48, :integer
  attribute :field_49, :integer
  attribute :field_50, :integer
  attribute :field_51, :integer
  attribute :field_52, :integer
  attribute :field_53, :string
  attribute :field_54
  attribute :field_55, :integer
  attribute :field_56, :integer
  attribute :field_57, :integer
  attribute :field_58, :integer
  attribute :field_59, :integer
  attribute :field_60, :integer
  attribute :field_61, :integer
  attribute :field_62, :string
  attribute :field_63, :string
  attribute :field_64, :string
  attribute :field_65, :integer
  attribute :field_66, :integer
  attribute :field_67, :integer
  attribute :field_68, :integer
  attribute :field_69, :integer
  attribute :field_70, :integer
  attribute :field_71, :integer
  attribute :field_72, :integer
  attribute :field_73, :integer
  attribute :field_74, :integer
  attribute :field_75, :integer
  attribute :field_76, :integer
  attribute :field_77, :integer
  attribute :field_78, :integer
  attribute :field_79, :integer
  attribute :field_80, :decimal
  attribute :field_81, :decimal
  attribute :field_82, :decimal
  attribute :field_83, :decimal
  attribute :field_84, :decimal
  attribute :field_85, :decimal
  attribute :field_86, :integer
  attribute :field_87, :integer
  attribute :field_88, :decimal
  attribute :field_89, :integer
  attribute :field_90, :integer
  attribute :field_91, :integer
  attribute :field_92, :integer
  attribute :field_93, :integer
  attribute :field_94, :integer
  attribute :field_95
  attribute :field_96, :integer
  attribute :field_97, :integer
  attribute :field_98, :integer
  attribute :field_99, :integer
  attribute :field_100, :string
  attribute :field_101, :integer
  attribute :field_102, :integer
  attribute :field_103, :integer
  attribute :field_104, :integer
  attribute :field_105, :integer
  attribute :field_106, :integer
  attribute :field_107, :string
  attribute :field_108, :string
  attribute :field_109, :string
  attribute :field_110
  attribute :field_111, :integer
  attribute :field_112, :string
  attribute :field_113, :integer
  attribute :field_114, :integer
  attribute :field_115
  attribute :field_116, :integer
  attribute :field_117, :integer
  attribute :field_118, :integer
  attribute :field_119, :integer
  attribute :field_120, :integer
  attribute :field_121, :integer
  attribute :field_122, :integer
  attribute :field_123, :integer
  attribute :field_124, :integer
  attribute :field_125, :integer
  attribute :field_126, :integer
  attribute :field_127, :integer
  attribute :field_128, :integer
  attribute :field_129, :integer
  attribute :field_130, :integer
  attribute :field_131, :string
  attribute :field_132, :integer
  attribute :field_133, :integer
  attribute :field_134, :integer

  validates :field_1, presence: true, inclusion: { in: (1..12).to_a }
  validates :field_4, presence: { if: proc { [1, 3, 5, 7, 9, 11].include?(field_1) } }
  validates :field_96, presence: true
  validates :field_97, presence: true
  validates :field_98, presence: true

  def attribute_set
    @attribute_set ||= instance_variable_get(:@attributes)
  end

  def validate_data_types
    unless attribute_set["field_1"].value_before_type_cast&.match?(/\A\d+\z/)
      errors.add(:field_1, :invalid)
    end
  end

  def valid?
    errors.clear

    super

    validate_data_types
    validate_nulls

    log.valid?

    log.errors.each do |error|
      fields = field_mapping_for_errors[error.attribute] || []
      fields.each { |field| errors.add(field, error.type) }
    end

    errors.blank?
  end

  def log
    @log ||= LettingsLog.new(attributes_for_log)
  end

private

  def postcode_full
    "#{field_108} #{field_109}" if field_108 && field_109
  end

  def postcode_known
    if postcode_full.present?
      1
    elsif field_107.present?
      0
    end
  end

  def questions
    log.form.subsections.flat_map { |ss| ss.applicable_questions(log) }
  end

  def validate_nulls
    field_mapping_for_errors.each do |error_key, fields|
      question_id = error_key.to_s
      question = questions.find { |q| q.id == question_id }

      next unless question
      next if log.optional_fields.include?(question.id)
      next if question.completed?(log)

      fields.each { |field| errors.add(field, :blank) }
    end
  end

  def field_mapping_for_errors
    {
      lettype: [:field_1],
      tenancycode: [:field_7],
      postcode_known: %i[field_107 field_108 field_109],
      postcode_full: %i[field_107 field_108 field_109],
      owning_organisation_id: [:field_111],
      managing_organisation_id: [:field_113],
      renewal: [:field_134],
      scheme: %i[field_4 field_5],
      created_by: [],
      needstype: [],
      rent_type: %i[field_1 field_129 field_130],
      startdate: %i[field_98 field_97 field_96],
      unittype_gn: %i[field_102],
      builtype: %i[field_103],
      wchair: %i[field_104],
      beds: %i[field_101],
      joint: %i[field_133],
      startertenancy: %i[field_8],
      tenancy: %i[field_9],
      declaration: %i[field_132],

      age1_known: %i[field_12],
      age1: %i[field_12],
      age2_known: %i[field_13],
      age2: %i[field_13],
      age3_known: %i[field_14],
      age3: %i[field_14],
      age4_known: %i[field_15],
      age4: %i[field_15],
      age5_known: %i[field_16],
      age5: %i[field_16],
      age6_known: %i[field_17],
      age6: %i[field_17],
      age7_known: %i[field_18],
      age7: %i[field_18],
      age8_known: %i[field_19],
      age8: %i[field_19],

      sex1: %i[field_20],
      sex2: %i[field_21],
      sex3: %i[field_22],
      sex4: %i[field_23],
      sex5: %i[field_24],
      sex6: %i[field_25],
      sex7: %i[field_26],
      sex8: %i[field_27],

      ethnic_group: %i[field_43],
      ethnic: %i[field_43],
      national: %i[field_44],

      relat2: %i[field_28],
      relat3: %i[field_29],
      relat4: %i[field_30],
      relat5: %i[field_31],
      relat6: %i[field_32],
      relat7: %i[field_33],
      relat8: %i[field_34],

      ecstat1: %i[field_35],
      ecstat2: %i[field_36],
      ecstat3: %i[field_37],
      ecstat4: %i[field_38],
      ecstat5: %i[field_39],
      ecstat6: %i[field_40],
      ecstat7: %i[field_41],
      ecstat8: %i[field_42],

      armedforces: %i[field_45],
      leftreg: %i[field_114],
      reservist: %i[field_46],

      preg_occ: %i[field_47],

      housingneeds: %i[field_47],

      illness: %i[field_118],

      layear: %i[field_66],
      waityear: %i[field_67],
      reason: %i[field_52],
      prevten: %i[field_61],
      homeless: %i[field_68],

      ppcodenk: %i[field_65],
      ppostcode_full: %i[field_65 field_66],

      reasonpref: %i[field_69],
      rp_homeless: %i[field_70],
      rp_insan_unsat: %i[field_71],
      rp_medwel: %i[field_72],
      rp_hardship: %i[field_73],
      rp_dontknow: %i[field_74],

      cbl: %i[field_75],
      chr: %i[field_76],
      cap: %i[field_77],

      referral: %i[field_78],

      net_income_known: %i[field_51],
      earnings: %i[field_50],
      incfreq: %i[field_116],
      hb: %i[field_48],
      benefits: %i[field_49],

      period: %i[field_79],
      brent: %i[field_80],
      hbrentshortfall: %i[field_87],
      tshortfall: %i[field_88],

      unitletas: %i[field_105],
      rsnvac: %i[field_106],
      sheltered: %i[field_117],

      illness_type_1: %i[field_119],
      illness_type_2: %i[field_120],
      illness_type_3: %i[field_121],
      illness_type_4: %i[field_122],
      illness_type_5: %i[field_123],
      illness_type_6: %i[field_124],
      illness_type_7: %i[field_125],
      illness_type_8: %i[field_126],
      illness_type_9: %i[field_127],
      illness_type_10: %i[field_128],

      irproduct_other: %i[field_131],
    }
  end

  def startdate
    Date.new(field_98, field_97, field_96) if field_98.present? && field_97.present? && field_96.present?
  end

  def renttype
    case field_1
    when 1, 2, 3, 4
      :social
    when 5, 6, 7, 8
      :affordable
    when 9, 10, 11, 12
      :intermediate
    end
  end

  def rent_type
    case renttype
    when :social
      Imports::LettingsLogsImportService::RENT_TYPE[:social_rent]
    when :affordable
      if field_129 == 1
        Imports::LettingsLogsImportService::RENT_TYPE[:london_affordable_rent]
      else
        Imports::LettingsLogsImportService::RENT_TYPE[:affordable_rent]
      end
    when :intermediate
      case field_130
      when 1
        Imports::LettingsLogsImportService::RENT_TYPE[:rent_to_buy]
      when 2
        Imports::LettingsLogsImportService::RENT_TYPE[:london_living_rent]
      when 3
        Imports::LettingsLogsImportService::RENT_TYPE[:other_intermediate_rent_product]
      end
    end
  end

  def owning_organisation_id
    Organisation.find_by(old_visible_id: field_111)&.id
  end

  def managing_organisation_id
    Organisation.find_by(old_visible_id: field_113)&.id
  end

  def attributes_for_log
    attributes = {}

    attributes["lettype"] = field_1
    attributes["tenancycode"] = field_7
    attributes["postcode_known"] = postcode_known
    attributes["postcode_full"] = postcode_full
    attributes["owning_organisation_id"] = owning_organisation_id
    attributes["managing_organisation_id"] = managing_organisation_id
    attributes["renewal"] = renewal
    attributes["scheme"] = scheme
    attributes["created_by"] = bulk_upload.user
    attributes["needstype"] = bulk_upload.needstype
    attributes["rent_type"] = rent_type
    attributes["startdate"] = startdate
    attributes["unittype_gn"] = field_102
    attributes["builtype"] = field_103
    attributes["wchair"] = field_104
    attributes["beds"] = field_101
    attributes["joint"] = field_133
    attributes["startertenancy"] = field_8
    attributes["tenancy"] = field_9
    attributes["declaration"] = field_132

    attributes["age1_known"] = field_12.present? ? 0 : 1
    attributes["age1"] = field_12
    attributes["age2_known"] = field_13.present? ? 0 : 1
    attributes["age2"] = field_13
    attributes["age3_known"] = field_14.present? ? 0 : 1
    attributes["age3"] = field_14
    attributes["age4_known"] = field_15.present? ? 0 : 1
    attributes["age4"] = field_15
    attributes["age5_known"] = field_16.present? ? 0 : 1
    attributes["age5"] = field_16
    attributes["age6_known"] = field_17.present? ? 0 : 1
    attributes["age6"] = field_17
    attributes["age7_known"] = field_18.present? ? 0 : 1
    attributes["age7"] = field_18
    attributes["age8_known"] = field_19.present? ? 0 : 1
    attributes["age8"] = field_19

    attributes["sex1"] = field_20
    attributes["sex2"] = field_21
    attributes["sex3"] = field_22
    attributes["sex4"] = field_23
    attributes["sex5"] = field_24
    attributes["sex6"] = field_25
    attributes["sex7"] = field_26
    attributes["sex8"] = field_27

    attributes["ethnic_group"] = ethnic_group_from_ethnic
    attributes["ethnic"] = field_43
    attributes["national"] = field_44

    attributes["relat2"] = field_28
    attributes["relat3"] = field_29
    attributes["relat4"] = field_30
    attributes["relat5"] = field_31
    attributes["relat6"] = field_32
    attributes["relat7"] = field_33
    attributes["relat8"] = field_34

    attributes["ecstat1"] = field_35
    attributes["ecstat2"] = field_36
    attributes["ecstat3"] = field_37
    attributes["ecstat4"] = field_38
    attributes["ecstat5"] = field_39
    attributes["ecstat6"] = field_40
    attributes["ecstat7"] = field_41
    attributes["ecstat8"] = field_42

    attributes["details_known_2"] = details_known(2)
    attributes["details_known_3"] = details_known(3)
    attributes["details_known_4"] = details_known(4)
    attributes["details_known_5"] = details_known(5)
    attributes["details_known_6"] = details_known(6)
    attributes["details_known_7"] = details_known(7)
    attributes["details_known_8"] = details_known(8)

    attributes["armedforces"] = field_45
    attributes["leftreg"] = leftreg
    attributes["reservist"] = field_46

    attributes["preg_occ"] = field_47

    attributes["housingneeds"] = housingneeds

    attributes["illness"] = field_118

    attributes["layear"] = field_66
    attributes["waityear"] = field_67
    attributes["reason"] = field_52
    attributes["prevten"] = field_61
    attributes["homeless"] = homeless

    attributes["ppcodenk"] = field_65
    attributes["ppostcode_full"] = ppostcode_full

    attributes["reasonpref"] = field_69
    attributes["rp_homeless"] = field_70
    attributes["rp_insan_unsat"] = field_71
    attributes["rp_medwel"] = field_72
    attributes["rp_hardship"] = field_73
    attributes["rp_dontknow"] = field_74

    attributes["cbl"] = cbl
    attributes["chr"] = chr
    attributes["cap"] = cap
    attributes["letting_allocation_unknown"] = letting_allocation_unknown

    attributes["referral"] = field_78

    attributes["net_income_known"] = net_income_known
    attributes["earnings"] = field_50
    attributes["incfreq"] = field_116
    attributes["hb"] = field_48
    attributes["benefits"] = field_49

    attributes["period"] = field_79
    attributes["brent"] = field_80
    attributes["hbrentshortfall"] = field_87
    attributes["tshortfall_known"] = tshortfall_known
    attributes["tshortfall"] = field_88

    attributes["hhmemb"] = hhmemb

    attributes["unitletas"] = field_105
    attributes["rsnvac"] = field_106
    attributes["sheltered"] = field_117

    attributes["illness_type_1"] = field_119
    attributes["illness_type_2"] = field_120
    attributes["illness_type_3"] = field_121
    attributes["illness_type_4"] = field_122
    attributes["illness_type_5"] = field_123
    attributes["illness_type_6"] = field_124
    attributes["illness_type_7"] = field_125
    attributes["illness_type_8"] = field_126
    attributes["illness_type_9"] = field_127
    attributes["illness_type_10"] = field_128

    attributes["irproduct_other"] = field_131

    attributes
  end

  def net_income_known
    case field_51
    when 1
      0
    when 2
      1
    when 3
      1
    when 4
      2
    end
  end

  def leftreg
    case field_114
    when 3
      3
    when 4
      1
    when 5
      2
    when 6
      0
    end
  end

  def homeless
    case field_68
    when 1
      1
    when 12
      11
    end
  end

  def renewal
    case field_134
    when 1
      1
    when 2
      0
    end
  end

  def details_known(person_n)
    send("person_#{person_n}_present?") ? 0 : 1
  end

  def hhmemb
    [
      person_2_present?,
      person_3_present?,
      person_4_present?,
      person_5_present?,
      person_6_present?,
      person_7_present?,
      person_8_present?,
    ].count(true) + 1
  end

  def person_2_present?
    field_13.present? && field_21.present? && field_28.present?
  end

  def person_3_present?
    field_14.present? && field_22.present? && field_29.present?
  end

  def person_4_present?
    field_15.present? && field_23.present? && field_30.present?
  end

  def person_5_present?
    field_16.present? && field_24.present? && field_31.present?
  end

  def person_6_present?
    field_17.present? && field_25.present? && field_32.present?
  end

  def person_7_present?
    field_18.present? && field_26.present? && field_33.present?
  end

  def person_8_present?
    field_19.present? && field_27.present? && field_34.present?
  end

  def tshortfall_known
    field_87 == 1 ? 0 : 1
  end

  def letting_allocation_unknown
    [cbl, chr, cap].all?(0) ? 1 : 0
  end

  def cbl
    field_75 == 2 ? 0 : field_75
  end

  def chr
    field_76 == 2 ? 0 : field_76
  end

  def cap
    field_77 == 2 ? 0 : field_77
  end

  def ppostcode_full
    "#{field_63} #{field_64}".strip.gsub(/\s+/, " ")
  end

  def housingneeds
    if field_59 == 1
      1
    elsif field_60 == 1
      3
    else
      2
    end
  end

  def ethnic_group_from_ethnic
    return nil if field_43.blank?

    case field_43
    when 1, 2, 3, 18
      0
    when 4, 5, 6, 7
      1
    when 8, 9, 10, 11, 15
      2
    when 12, 13, 14
      3
    when 16, 19
      4
    when 17
      17
    end
  end

  def scheme
    @scheme ||= Scheme.find_by(old_visible_id: field_4)
  end
end
