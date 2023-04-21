class BulkUpload::Sales::Year2022::RowParser
  include ActiveModel::Model
  include ActiveModel::Attributes

  QUESTIONS = {
    field_1: "What is the purchaser code?",
    field_2: "What is the day of the sale completion date? - DD",
    field_3: "What is the month of the sale completion date? - MM",
    field_4: "What is the year of the sale completion date? - YY",
    field_5: "This question has been removed",
    field_6: "Was the buyer interviewed for any of the answers you will provide on this log?",
    field_7: "Age of buyer 1",
    field_8: "Age of person 2",
    field_9: "Age of person 3",
    field_10: "Age of person 4",
    field_11: "Age of person 5",
    field_12: "Age of person 6",
    field_13: "Gender identity of buyer 1",
    field_14: "Gender identity of person 2",
    field_15: "Gender identity of person 3",
    field_16: "Gender identity of person 4",
    field_17: "Gender identity of person 5",
    field_18: "Gender identity of person 6",
    field_19: "Relationship to buyer 1 for person 2",
    field_20: "Relationship to buyer 1 for person 3",
    field_21: "Relationship to buyer 1 for person 4",
    field_22: "Relationship to buyer 1 for person 5",
    field_23: "Relationship to buyer 1 for person 6",
    field_24: "Working situation of buyer 1",
    field_25: "Working situation of person 2",
    field_26: "Working situation of person 3",
    field_27: "Working situation of person 4",
    field_28: "Working situation of person 5",
    field_29: "Working situation of person 6",
    field_30: "What is buyer 1's ethnic group?",
    field_31: "What is buyer 1's nationality?",
    field_32: "What is buyer 1's gross annual income?",
    field_33: "What is buyer 2's gross annual income?",
    field_34: "Was buyer 1's income used for a mortgage application?",
    field_35: "Was buyer 2's income used for a mortgage application?",
    field_36: "What is the total amount the buyers had in savings before they paid any deposit for the property?",
    field_37: "Have any of the purchasers previously owned a property?",
    field_38: "This question has been removed",
    field_39: "What was buyer 1's previous tenure?",
    field_40: "What is the local authority of buyer 1's last settled home?",
    field_41: "Part 1 of postcode of buyer 1's last settled home",
    field_42: "Part 2 of postcode of buyer 1's last settled home",
    field_43: "Do you know the postcode of buyer 1's last settled home?",
    field_44: "Was the buyer registered with their PRP (HA)?",
    field_45: "Was the buyer registered with the local authority?",
    field_46: "Was the buyer registered with a Help to Buy agent?",
    field_47: "Was the buyer registered with another PRP (HA)?",
    field_48: "Does anyone in the household consider themselves to have a disability?",
    field_49: "Does anyone in the household use a wheelchair?",
    field_50: "How many bedrooms does the property have?",
    field_51: "What type of unit is the property?",
    field_52: "Which type of bulding is the property?",
    field_53: "What is the local authority of the property?",
    field_54: "Part 1 of postcode of property",
    field_55: "Part 2 of postcode of property",
    field_56: "Is the property built or adapted to wheelchair user standards?",
    field_57: "What is the type of shared ownership sale?",
    field_58: "Is this a resale?",
    field_59: "What is the day of the practical completion or handover date?",
    field_60: "What is the month of the practical completion or handover date?",
    field_61: "What is the day of the exchange of contracts date?",
    field_62: "What is the day of the practical completion or handover date?",
    field_63: "What is the month of the practical completion or handover date?",
    field_64: "What is the year of the practical completion or handover date?",
    field_65: "Was the household re-housed under a local authority nominations agreement?",
    field_66: "How many bedrooms did the buyer's previous property have?",
    field_67: "What was the type of the buyer's previous property?",
    field_68: "What was the full purchase price?",
    field_69: "What was the initial percentage equity stake purchased?",
    field_70: "What is the mortgage amount?",
    field_71: "Does this include any extra borrowing?",
    field_72: "How much was the cash deposit paid on the property?",
    field_73: "How much cash discount was given through Social Homebuy?",
    field_74: "What is the basic monthly rent?",
    field_75: "What are the total monthly leasehold charges for the property?",
    field_76: "What is the type of discounted ownership sale?",
    field_77: "What was the full purchase price?",
    field_78: "What was the amount of any loan, grant, discount or subsidy given?",
    field_79: "What was the percentage discount?",
    field_80: "What is the mortgage amount?",
    field_81: "Does this include any extra borrowing?",
    field_82: "How much was the cash deposit paid on the property?",
    field_83: "What are the total monthly leasehold charges for the property?",
    field_84: "What is the type of outright sale?",
    field_85: "If 'other', what is the 'other' type?",
    field_86: "This question has been removed",
    field_87: "What is the full purchase price?",
    field_88: "What is the mortgage amount?",
    field_89: "Does this include any extra borrowing?",
    field_90: "How much was the cash deposit paid on the property?",
    field_91: "What are the total monthly leasehold charges for the property?",
    field_92: "Which organisation owned this property before the sale?",
    field_93: "Username",
    field_94: "This question has been removed",
    field_95: "Has the buyer ever served in the UK Armed Forces and for how long?",
    field_96: "This question has been removed",
    field_97: "Are any of the buyers a spouse or civil partner of a UK Armed Forces regular who died in service within the last 2 years?",
    field_98: "What is the name of the mortgage lender? - Shared ownership",
    field_99: "If 'other', what is the name of the mortgage lender?",
    field_100: "What is the name of the mortgage lender? - Discounted ownership",
    field_101: "If 'other', what is the name of the mortgage lender?",
    field_102: "What is the name of the mortgage lender? - Outright sale",
    field_103: "If 'other', what is the name of the mortgage lender?",
    field_104: "Were the buyers receiving any of these housing-related benefits immediately before buying this property?",
    field_105: "What is the length of the mortgage in years? - Shared ownership",
    field_106: "What is the length of the mortgage in years? - Discounted ownership",
    field_107: "What is the length of the mortgage in years? - Outright sale",
    field_108: "How long have the buyers been living in the property before the purchase? - Discounted ownership",
    field_109: "Are there more than two joint purchasers of this property?",
    field_110: "How long have the buyers been living in the property before the purchase? - Shared ownership",
    field_111: "Is this a staircasing transaction?",
    field_112: "Data Protection question",
    field_113: "Was this purchase made through an ownership scheme?",
    field_114: "Is the buyer a company?",
    field_115: "Will the buyers live in the property?",
    field_116: "Is this a joint purchase?",
    field_117: "Will buyer 1 live in the property?",
    field_118: "Will buyer 2 live in the property?",
    field_119: "Besides the buyers, how many people will live in the property?",
    field_120: "What percentage of the property has been bought in this staircasing transaction?",
    field_121: "What percentage of the property does the buyer now own in total?",
    field_122: "What was the rent type of the buyer's previous property?",
    field_123: "Was a mortgage used for the purchase of this property? - Shared ownership",
    field_124: "Was a mortgage used for the purchase of this property? - Discounted ownership",
    field_125: "Was a mortgage used for the purchase of this property? - Outright sale",
  }.freeze

  attribute :bulk_upload
  attribute :block_log_creation, :boolean, default: -> { false }

  attribute :field_1, :string
  attribute :field_2, :integer
  attribute :field_3, :integer
  attribute :field_4, :integer
  attribute :field_5
  attribute :field_6, :integer
  attribute :field_7, :string
  attribute :field_8, :string
  attribute :field_9, :string
  attribute :field_10, :string
  attribute :field_11, :string
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
  attribute :field_24, :integer
  attribute :field_25, :integer
  attribute :field_26, :integer
  attribute :field_27, :integer
  attribute :field_28, :integer
  attribute :field_29, :integer
  attribute :field_30, :integer
  attribute :field_31, :integer
  attribute :field_32, :integer
  attribute :field_33, :integer
  attribute :field_34, :integer
  attribute :field_35, :integer
  attribute :field_36, :integer
  attribute :field_37, :integer
  attribute :field_38
  attribute :field_39, :integer
  attribute :field_40, :string
  attribute :field_41, :string
  attribute :field_42, :string
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
  attribute :field_54, :string
  attribute :field_55, :string
  attribute :field_56, :integer
  attribute :field_57, :integer
  attribute :field_58, :integer
  attribute :field_59, :integer
  attribute :field_60, :integer
  attribute :field_61, :integer
  attribute :field_62, :integer
  attribute :field_63, :integer
  attribute :field_64, :integer
  attribute :field_65, :integer
  attribute :field_66, :integer
  attribute :field_67, :integer
  attribute :field_68, :integer
  attribute :field_69, :integer
  attribute :field_70, :integer
  attribute :field_71, :integer
  attribute :field_72, :integer
  attribute :field_73, :integer
  attribute :field_74, :decimal
  attribute :field_75, :decimal
  attribute :field_76, :integer
  attribute :field_77, :integer
  attribute :field_78, :integer
  attribute :field_79, :integer
  attribute :field_80, :integer
  attribute :field_81, :integer
  attribute :field_82, :integer
  attribute :field_83, :integer
  attribute :field_84, :integer
  attribute :field_85, :string
  attribute :field_86
  attribute :field_87, :integer
  attribute :field_88, :integer
  attribute :field_89, :integer
  attribute :field_90, :integer
  attribute :field_91, :integer
  attribute :field_92, :string
  attribute :field_93, :string
  attribute :field_94
  attribute :field_95, :integer
  attribute :field_96
  attribute :field_97, :integer
  attribute :field_98, :integer
  attribute :field_99, :string
  attribute :field_100, :integer
  attribute :field_101, :string
  attribute :field_102, :integer
  attribute :field_103, :string
  attribute :field_104, :integer
  attribute :field_105, :integer
  attribute :field_106, :integer
  attribute :field_107, :integer
  attribute :field_108, :integer
  attribute :field_109, :integer
  attribute :field_110, :integer
  attribute :field_111, :integer
  attribute :field_112, :integer
  attribute :field_113, :integer
  attribute :field_114, :integer
  attribute :field_115, :integer
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

  validates :field_2, presence: { message: I18n.t("validations.not_answered", question: "sale completion date (day)") }, on: :after_log
  validates :field_3, presence: { message: I18n.t("validations.not_answered", question: "sale completion date (month)") }, on: :after_log
  validates :field_4, presence: { message: I18n.t("validations.not_answered", question: "sale completion date (year)") }, on: :after_log
  validates :field_4, format: { with: /\A\d{2}\z/, message: I18n.t("validations.setup.saledate.year_not_two_digits") }, on: :after_log

  validates :field_113, presence: { message: I18n.t("validations.not_answered", question: "ownership type") }, on: :after_log
  validates :field_57, presence: { message: I18n.t("validations.not_answered", question: "shared ownership type") }, if: :shared_ownership?, on: :after_log
  validates :field_76, presence: { message: I18n.t("validations.not_answered", question: "shared ownership type") }, if: :discounted_ownership?, on: :after_log
  validates :field_84, presence: { message: I18n.t("validations.not_answered", question: "shared ownership type") }, if: :outright_sale?, on: :after_log
  validates :field_115, presence: { message: I18n.t("validations.not_answered", question: "will the buyers live in the property") }, if: :outright_sale?, on: :after_log
  validates :field_116, presence: { message: I18n.t("validations.not_answered", question: "joint purchase") }, if: :joint_purchase_asked?, on: :after_log
  validates :field_114, presence: { message: I18n.t("validations.not_answered", question: "company buyer") }, if: :outright_sale?, on: :after_log
  validates :field_109, presence: { message: I18n.t("validations.not_answered", question: "more than 2 buyers") }, if: :joint_purchase?, on: :after_log

  validate :validate_nulls, on: :after_log
  validate :validate_valid_radio_option, on: :before_log

  validate :validate_owning_org_data_given, on: :after_log
  validate :validate_owning_org_exists, on: :after_log
  validate :validate_owning_org_permitted, on: :after_log

  validate :validate_created_by_exists, on: :after_log
  validate :validate_created_by_related, on: :after_log
  validate :validate_relevant_collection_window, on: :after_log

  def self.question_for_field(field)
    QUESTIONS[field]
  end

  def attribute_set
    @attribute_set ||= instance_variable_get(:@attributes)
  end

  def blank_row?
    attribute_set
      .to_hash
      .reject { |k, _| %w[bulk_upload block_log_creation].include?(k) }
      .values
      .compact
      .empty?
  end

  def log
    @log ||= SalesLog.new(attributes_for_log)
  end

  def valid?
    errors.clear

    return true if blank_row?

    super(:before_log)
    before_errors = errors.dup

    log.valid?

    super(:after_log)
    errors.merge!(before_errors)

    log.errors.each do |error|
      fields = field_mapping_for_errors[error.attribute] || []

      fields.each do |field|
        unless errors.include?(field)
          errors.add(field, error.message)
        end
      end
    end

    errors.blank?
  end

  def block_log_creation?
    block_log_creation
  end

private

  def shared_ownership?
    field_113 == 1
  end

  def discounted_ownership?
    field_113 == 2
  end

  def outright_sale?
    field_113 == 3
  end

  def joint_purchase?
    field_116 == 1
  end

  def joint_purchase_asked?
    shared_ownership? || discounted_ownership? || field_114 == 2
  end

  def field_mapping_for_errors
    {
      purchid: %i[field_1],
      saledate: %i[field_2 field_3 field_4],
      noint: %i[field_6],
      age1_known: %i[field_7],
      age1: %i[field_7],
      age2_known: %i[field_8],
      age2: %i[field_8],
      age3_known: %i[field_9],
      age3: %i[field_9],
      age4_known: %i[field_10],
      age4: %i[field_10],
      age5_known: %i[field_11],
      age5: %i[field_11],
      age6_known: %i[field_12],
      age6: %i[field_12],
      sex1: %i[field_13],
      sex2: %i[field_14],
      sex3: %i[field_15],
      sex4: %i[field_16],
      sex5: %i[field_17],
      sex6: %i[field_18],
      relat2: %i[field_19],
      relat3: %i[field_20],
      relat4: %i[field_21],
      relat5: %i[field_22],
      relat6: %i[field_23],
      ecstat1: %i[field_24],
      ecstat2: %i[field_25],
      ecstat3: %i[field_26],
      ecstat4: %i[field_27],
      ecstat5: %i[field_28],
      ecstat6: %i[field_29],
      ethnic_group: %i[field_30],
      ethnic: %i[field_30],
      national: %i[field_31],
      income1nk: %i[field_32],
      income1: %i[field_32],
      income2nk: %i[field_33],
      income2: %i[field_33],
      inc1mort: %i[field_34],
      inc2mort: %i[field_35],
      savingsnk: %i[field_36],
      savings: %i[field_36],
      prevown: %i[field_37],
      prevten: %i[field_39],
      prevloc: %i[field_40],
      previous_la_known: %i[field_40],
      ppcodenk: %i[field_43],
      ppostcode_full: %i[field_41 field_42],
      pregyrha: %i[field_44],
      pregla: %i[field_45],
      pregghb: %i[field_46],
      pregother: %i[field_47],
      pregblank: %i[field_44 field_45 field_46 field_47],
      disabled: %i[field_48],
      wheel: %i[field_49],
      beds: %i[field_50],
      proptype: %i[field_51],
      builtype: %i[field_52],
      la_known: %i[field_53],
      la: %i[field_53],
      is_la_inferred: %i[field_53],
      pcodenk: %i[field_54 field_55],
      postcode_full: %i[field_54 field_55],
      wchair: %i[field_56],
      type: %i[field_57 field_76 field_84 field_113],
      resale: %i[field_58],
      hodate: %i[field_59 field_60 field_61],
      exdate: %i[field_62 field_63 field_64],
      lanomagr: %i[field_65],
      frombeds: %i[field_66],
      fromprop: %i[field_67],
      value: %i[field_68 field_77 field_87],
      equity: %i[field_69],
      mortgage: %i[field_70 field_80 field_88],
      extrabor: %i[field_71 field_81 field_89],
      deposit: %i[field_72 field_82 field_90],
      cashdis: %i[field_73],
      mrent: %i[field_74],
      has_mscharge: %i[field_75 field_83 field_91],
      mscharge: %i[field_75 field_83 field_91],
      grant: %i[field_78],
      discount: %i[field_79],
      othtype: %i[field_85],
      owning_organisation_id: %i[field_92],
      created_by: %i[field_93],
      hhregres: %i[field_95],
      hhregresstill: %i[field_95],
      armedforcesspouse: %i[field_97],
      mortgagelender: %i[field_98 field_100 field_102],
      mortgagelenderother: %i[field_99 field_101 field_103],
      hb: %i[field_104],
      mortlen: %i[field_105 field_106 field_107],
      proplen: %i[field_108 field_110],
      jointmore: %i[field_109],
      staircase: %i[field_111],
      privacynotice: %i[field_112],
      ownershipsch: %i[field_113],
      companybuy: %i[field_114],
      buylivein: %i[field_115],
      jointpur: %i[field_116],
      buy1livein: %i[field_117],
      buy2livein: %i[field_118],
      hholdcount: %i[field_119],
      stairbought: %i[field_120],
      stairowned: %i[field_121],
      socprevten: %i[field_122],
      mortgageused: %i[field_123 field_124 field_125],
      soctenant: %i[field_39 field_113],
    }
  end

  def attributes_for_log
    attributes = {}
    attributes["purchid"] = field_1
    attributes["saledate"] = saledate

    attributes["noint"] = 2 if field_6 == 1

    attributes["details_known_2"] = details_known?(2)
    attributes["details_known_3"] = details_known?(3)
    attributes["details_known_4"] = details_known?(4)
    attributes["details_known_5"] = details_known?(5)
    attributes["details_known_6"] = details_known?(6)

    attributes["age1_known"] = age1_known?
    attributes["age1"] = field_7 if attributes["age1_known"].zero? && field_7&.match(/\A\d{1,3}\z|\AR\z/)

    attributes["age2_known"] = age2_known?
    attributes["age2"] = field_8 if attributes["age2_known"].zero? && field_8&.match(/\A\d{1,3}\z|\AR\z/)

    attributes["age3_known"] = age3_known?
    attributes["age3"] = field_9 if attributes["age3_known"].zero? && field_9&.match(/\A\d{1,3}\z|\AR\z/)

    attributes["age4_known"] = age4_known?
    attributes["age4"] = field_10 if attributes["age4_known"].zero? && field_10&.match(/\A\d{1,3}\z|\AR\z/)

    attributes["age5_known"] = age5_known?
    attributes["age5"] = field_11 if attributes["age5_known"].zero? && field_11&.match(/\A\d{1,3}\z|\AR\z/)

    attributes["age6_known"] = age6_known?
    attributes["age6"] = field_12 if attributes["age6_known"].zero? && field_12&.match(/\A\d{1,3}\z|\AR\z/)

    attributes["sex1"] = field_13
    attributes["sex2"] = field_14
    attributes["sex3"] = field_15
    attributes["sex4"] = field_16
    attributes["sex5"] = field_17
    attributes["sex6"] = field_18

    attributes["relat2"] = field_19
    attributes["relat3"] = field_20
    attributes["relat4"] = field_21
    attributes["relat5"] = field_22
    attributes["relat6"] = field_23

    attributes["ecstat1"] = field_24
    attributes["ecstat2"] = field_25
    attributes["ecstat3"] = field_26
    attributes["ecstat4"] = field_27
    attributes["ecstat5"] = field_28
    attributes["ecstat6"] = field_29

    attributes["ethnic_group"] = ethnic_group_from_ethnic
    attributes["ethnic"] = field_30
    attributes["national"] = field_31
    attributes["income1nk"] = field_32.present? ? 0 : 1
    attributes["income1"] = field_32
    attributes["income2nk"] = field_33.present? ? 0 : 1
    attributes["income2"] = field_33
    attributes["inc1mort"] = field_34
    attributes["inc2mort"] = field_35
    attributes["savingsnk"] = field_36.present? ? 0 : 1
    attributes["savings"] = field_36
    attributes["prevown"] = field_37

    attributes["prevten"] = field_39
    attributes["prevloc"] = field_40
    attributes["previous_la_known"] = previous_la_known
    attributes["ppcodenk"] = field_43
    attributes["ppostcode_full"] = ppostcode_full

    attributes["pregyrha"] = field_44
    attributes["pregla"] = field_45
    attributes["pregghb"] = field_46
    attributes["pregother"] = field_47
    attributes["pregblank"] = 1 if [field_44, field_45, field_46, field_47].all?(&:blank?)

    attributes["disabled"] = field_48
    attributes["wheel"] = field_49
    attributes["beds"] = field_50
    attributes["proptype"] = field_51
    attributes["builtype"] = field_52
    attributes["la_known"] = field_53.present? ? 1 : 0
    attributes["la"] = field_53
    attributes["is_la_inferred"] = false
    attributes["pcodenk"] = 0 if postcode_full.present?
    attributes["postcode_full"] = postcode_full
    attributes["wchair"] = field_56

    attributes["type"] = sale_type

    attributes["resale"] = field_58

    attributes["hodate"] = hodate
    attributes["exdate"] = exdate

    attributes["lanomagr"] = field_65

    attributes["frombeds"] = field_66
    attributes["fromprop"] = field_67

    attributes["value"] = value
    attributes["equity"] = field_69
    attributes["mortgage"] = mortgage
    attributes["extrabor"] = extrabor
    attributes["deposit"] = deposit
    attributes["cashdis"] = field_73
    attributes["mrent"] = field_74
    attributes["has_mscharge"] = mscharge.present? ? 1 : 0
    attributes["mscharge"] = mscharge
    attributes["grant"] = field_78
    attributes["discount"] = field_79

    attributes["othtype"] = field_85

    attributes["owning_organisation_id"] = owning_organisation_id
    attributes["created_by"] = created_by || bulk_upload.user
    attributes["hhregres"] = hhregres
    attributes["hhregresstill"] = hhregresstill
    attributes["armedforcesspouse"] = field_97

    attributes["mortgagelender"] = mortgagelender
    attributes["mortgagelenderother"] = mortgagelenderother

    attributes["hb"] = field_104

    attributes["mortlen"] = mortlen

    attributes["proplen"] = proplen
    attributes["jointmore"] = field_109
    attributes["staircase"] = field_111
    attributes["privacynotice"] = field_112
    attributes["ownershipsch"] = field_113
    attributes["companybuy"] = field_114
    attributes["buylivein"] = field_115
    attributes["jointpur"] = field_116
    attributes["buy1livein"] = field_117
    attributes["buy2livein"] = field_118
    attributes["hholdcount"] = field_119
    attributes["stairbought"] = field_120
    attributes["stairowned"] = field_121
    attributes["socprevten"] = field_122
    attributes["mortgageused"] = mortgageused
    attributes["soctenant"] = soctenant

    attributes
  end

  def saledate
    Date.new(field_4 + 2000, field_3, field_2) if field_2.present? && field_3.present? && field_4.present?
  rescue Date::Error
    Date.new
  end

  def hodate
    Date.new(field_61 + 2000, field_60, field_59) if field_59.present? && field_60.present? && field_61.present?
  rescue Date::Error
    Date.new
  end

  def exdate
    Date.new(field_64 + 2000, field_63, field_62) if field_62.present? && field_63.present? && field_64.present?
  rescue Date::Error
    Date.new
  end

  def age1_known?
    return 1 if field_7 == "R"
    return 1 if field_7.blank?

    0
  end

  [
    { person: 2, field: :field_8 },
    { person: 3, field: :field_9 },
    { person: 4, field: :field_10 },
    { person: 5, field: :field_11 },
    { person: 6, field: :field_12 },
  ].each do |hash|
    define_method("age#{hash[:person]}_known?") do
      return 1 if public_send(hash[:field]) == "R"
      return 0 if send("person_#{hash[:person]}_present?")
      return 1 if public_send(hash[:field]).blank?

      0
    end
  end

  def person_2_present?
    field_8.present? || field_14.present? || field_19.present?
  end

  def person_3_present?
    field_9.present? || field_15.present? || field_20.present?
  end

  def person_4_present?
    field_10.present? || field_16.present? || field_21.present?
  end

  def person_5_present?
    field_11.present? || field_17.present? || field_22.present?
  end

  def person_6_present?
    field_12.present? || field_18.present? || field_23.present?
  end

  def details_known?(person_n)
    send("person_#{person_n}_present?") ? 1 : 2
  end

  def ethnic_group_from_ethnic
    return nil if field_30.blank?

    case field_30
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

  def postcode_full
    "#{field_54} #{field_55}" if field_54 && field_55
  end

  def ppostcode_full
    "#{field_41} #{field_42}" if field_41 && field_42
  end

  def sale_type
    return field_57 if shared_ownership?
    return field_76 if discounted_ownership?
    return field_84 if outright_sale?
  end

  def value
    return field_68 if shared_ownership?
    return field_77 if discounted_ownership?
    return field_87 if outright_sale?
  end

  def mortgage
    return field_70 if shared_ownership?
    return field_80 if discounted_ownership?
    return field_88 if outright_sale?
  end

  def extrabor
    return field_71 if shared_ownership?
    return field_81 if discounted_ownership?
    return field_89 if outright_sale?
  end

  def deposit
    return field_72 if shared_ownership?
    return field_82 if discounted_ownership?
    return field_90 if outright_sale?
  end

  def mscharge
    return field_75 if shared_ownership?
    return field_83 if discounted_ownership?
    return field_91 if outright_sale?
  end

  def mortgagelender
    return field_98 if shared_ownership?
    return field_100 if discounted_ownership?
    return field_102 if outright_sale?
  end

  def mortgagelenderother
    return field_99 if shared_ownership?
    return field_101 if discounted_ownership?
    return field_103 if outright_sale?
  end

  def mortlen
    return field_105 if shared_ownership?
    return field_106 if discounted_ownership?
    return field_107 if outright_sale?
  end

  def proplen
    return field_110 if shared_ownership?
    return field_108 if discounted_ownership?
  end

  def mortgageused
    return field_123 if shared_ownership?
    return field_124 if discounted_ownership?
    return field_125 if outright_sale?
  end

  def owning_organisation
    Organisation.find_by_id_on_multiple_fields(field_92)
  end

  def owning_organisation_id
    owning_organisation&.id
  end

  def created_by
    @created_by ||= User.find_by(email: field_93)
  end

  def hhregres
    case field_95
    when 3 then 3
    when 4, 5, 6 then 1
    when 7 then 7
    when 8 then 8
    end
  end

  def hhregresstill
    return unless hhregres == 1

    field_95
  end

  def previous_la_known
    field_40.present? ? 1 : 0
  end

  def soctenant
    return unless field_39 && field_113

    if (field_39 == 1 || fields_39 == 2) && field_113 == 1
      1
    elsif field_113 == 1
      2
    end
  end

  def block_log_creation!
    self.block_log_creation = true
  end

  def questions
    @questions ||= log.form.subsections.flat_map { |ss| ss.applicable_questions(log) }
  end

  def validate_owning_org_data_given
    if field_92.blank?
      block_log_creation!

      if errors[:field_92].blank?
        errors.add(:field_92, "The owning organisation code is incorrect", category: :setup)
      end
    end
  end

  def validate_owning_org_exists
    if owning_organisation.nil?
      block_log_creation!

      if errors[:field_92].blank?
        errors.add(:field_92, "The owning organisation code is incorrect", category: :setup)
      end
    end
  end

  def validate_owning_org_owns_stock
    if owning_organisation && !owning_organisation.holds_own_stock?
      block_log_creation!

      if errors[:field_92].blank?
        errors.add(:field_92, "The owning organisation code provided is for an organisation that does not own stock", category: :setup)
      end
    end
  end

  def validate_owning_org_permitted
    if owning_organisation && !bulk_upload.user.organisation.affiliated_stock_owners.include?(owning_organisation)
      block_log_creation!

      if errors[:field_92].blank?
        errors.add(:field_92, "You do not have permission to add logs for this owning organisation", category: :setup)
      end
    end
  end

  def validate_created_by_exists
    return if field_93.blank?

    unless created_by
      errors.add(:field_93, "User with the specified email could not be found")
    end
  end

  def validate_created_by_related
    return unless created_by

    unless created_by.organisation == owning_organisation
      block_log_creation!
      errors.add(:field_93, "User must be related to owning organisation")
    end
  end

  def setup_question?(question)
    log.form.setup_sections[0].subsections[0].questions.include?(question)
  end

  def validate_nulls
    field_mapping_for_errors.each do |error_key, fields|
      question_id = error_key.to_s
      question = questions.find { |q| q.id == question_id }

      next unless question
      next if log.optional_fields.include?(question.id)
      next if question.completed?(log)

      if setup_question?(question)
        fields.each do |field|
          if errors[field].present?
            errors.add(field, I18n.t("validations.not_answered", question: question.check_answer_label&.downcase), category: :setup)
          end
        end
      else
        fields.each do |field|
          unless errors.any? { |e| fields.include?(e.attribute) }
            errors.add(field, I18n.t("validations.not_answered", question: question.check_answer_label&.downcase))
          end
        end
      end
    end
  end

  def validate_valid_radio_option
    log.attributes.each do |question_id, _v|
      question = log.form.get_question(question_id, log)

      next unless question&.type == "radio"
      next if log[question_id].blank? || question.answer_options.key?(log[question_id].to_s) || !question.page.routed_to?(log, nil)

      fields = field_mapping_for_errors[question_id.to_sym] || []

      if setup_question?(question)
        fields.each do |field|
          if errors[field].present?
            errors.add(field, I18n.t("validations.invalid_option", question: QUESTIONS[field]), category: :setup)
          end
        end
      else
        fields.each do |field|
          unless errors.any? { |e| fields.include?(e.attribute) }
            errors.add(field, I18n.t("validations.invalid_option", question: QUESTIONS[field]))
          end
        end
      end
    end
  end

  def validate_relevant_collection_window
    return if saledate.blank? || bulk_upload.form.blank?

    unless bulk_upload.form.valid_start_date_for_form?(saledate)
      errors.add(:field_2, I18n.t("validations.date.outside_collection_window"))
      errors.add(:field_3, I18n.t("validations.date.outside_collection_window"))
      errors.add(:field_4, I18n.t("validations.date.outside_collection_window"))
    end
  end
end
