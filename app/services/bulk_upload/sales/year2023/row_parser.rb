class BulkUpload::Sales::Year2023::RowParser
  include ActiveModel::Model
  include ActiveModel::Attributes
  include InterruptionScreenHelper
  include FormattingHelper

  QUESTIONS = {
    field_1: "Which organisation owned this property before the sale?",
    field_2: "Username",
    field_3: "What is the day of the sale completion date? - DD",
    field_4: "What is the month of the sale completion date? - MM",
    field_5: "What is the year of the sale completion date? - YY",
    field_6: "What is the purchaser code?",
    field_7: "Was this purchase made through an ownership scheme?",
    field_8: "What is the type of shared ownership sale?",
    field_9: "What is the type of discounted ownership sale?",
    field_10: "What is the type of outright sale?",

    field_11: "If 'other', what is the 'other' type?",
    field_12: "Is the buyer a company?",
    field_13: "Will the buyers live in the property?",
    field_14: "Is this a joint purchase?",
    field_15: "Are there more than two joint purchasers of this property?",
    field_16: "How many bedrooms does the property have?",
    field_17: "What type of unit is the property?",
    field_18: "Which type of bulding is the property?",
    field_19: "If known, enter this property's UPRN",
    field_20: "Address line 1",

    field_21: "Address line 2",
    field_22: "Town or city",
    field_23: "County",
    field_24: "Part 1 of postcode of property",
    field_25: "Part 2 of postcode of property",
    field_26: "What is the local authority of the property?",
    field_27: "Is the property built or adapted to wheelchair user standards?",
    field_28: "Was the buyer interviewed for any of the answers you will provide on this log?",
    field_29: "Data Protection question",
    field_30: "Age of buyer 1",

    field_31: "Gender identity of buyer 1",
    field_32: "What is buyer 1's ethnic group?",
    field_33: "What is buyer 1's nationality?",
    field_34: "If 'Any other country', what is buyer 1's nationality?",
    field_35: "Working situation of buyer 1",
    field_36: "Will buyer 1 live in the property?",
    field_37: "Relationship to buyer 1 for person 2",
    field_38: "Age of person 2",
    field_39: "Gender identity of person 2",
    field_40: "Which of the following best describes buyer 2's ethnic background?",

    field_41: "What is buyer 2's nationality?",
    field_42: "If 'Any other country', what is buyer 2's nationality?",
    field_43: "What is buyer 2 or person 2's working situation?",
    field_44: "Will buyer 2 live in the property?",
    field_45: "Besides the buyers, how many people will live in the property?",
    field_46: "Relationship to buyer 1 for person 3",
    field_47: "Age of person 3",
    field_48: "Gender identity of person 3",
    field_49: "Working situation of person 3",
    field_50: "Relationship to buyer 1 for person 4",

    field_51: "Age of person 4",
    field_52: "Gender identity of person 4",
    field_53: "Working situation of person 4",
    field_54: "Relationship to buyer 1 for person 5",
    field_55: "Age of person 5",
    field_56: "Gender identity of person 5",
    field_57: "Working situation of person 5",
    field_58: "Relationship to buyer 1 for person 6",
    field_59: "Age of person 6",
    field_60: "Gender identity of person 6",

    field_61: "Working situation of person 6",
    field_62: "What was buyer 1's previous tenure?",
    field_63: "Do you know the postcode of buyer 1's last settled home?",
    field_64: "Part 1 of postcode of buyer 1's last settled home",
    field_65: "Part 2 of postcode of buyer 1's last settled home",
    field_66: "What is the local authority of buyer 1's last settled home?",
    field_67: "Was the buyer registered with their PRP (HA)?",
    field_68: "Was the buyer registered with another PRP (HA)?",
    field_69: "Was the buyer registered with the local authority?",
    field_70: "Was the buyer registered with a Help to Buy agent?",

    field_71: "At the time of purchase, was buyer 2 living at the same address as buyer 1?",
    field_72: "What was buyer 2's previous tenure?",
    field_73: "Has the buyer ever served in the UK Armed Forces and for how long?",
    field_74: "Is the buyer still serving in the UK armed forces?",
    field_75: "Are any of the buyers a spouse or civil partner of a UK Armed Forces regular who died in service within the last 2 years?",
    field_76: "Does anyone in the household consider themselves to have a disability?",
    field_77: "Does anyone in the household use a wheelchair?",
    field_78: "What is buyer 1's gross annual income?",
    field_79: "Was buyer 1's income used for a mortgage application?",
    field_80: "What is buyer 2's gross annual income?",

    field_81: "Was buyer 2's income used for a mortgage application?",
    field_82: "Were the buyers receiving any of these housing-related benefits immediately before buying this property?",
    field_83: "What is the total amount the buyers had in savings before they paid any deposit for the property?",
    field_84: "Have any of the purchasers previously owned a property?",
    field_85: "Was the previous property under shared ownership?",
    field_86: "How long have the buyers been living in the property before the purchase? - Shared ownership",
    field_87: "Is this a staircasing transaction?",
    field_88: "What percentage of the property has been bought in this staircasing transaction?",
    field_89: "What percentage of the property does the buyer now own in total?",
    field_90: "Was this transaction part of a back-to-back staircasing transaction to facilitate sale of the home on the open market?",

    field_91: "Is this a resale?",
    field_92: "What is the day of the exchange of contracts date?",
    field_93: "What is the month of the exchange of contracts date?",
    field_94: "What is the year of the exchange of contracts date?",
    field_95: "What is the day of the practical completion or handover date?",
    field_96: "What is the month of the practical completion or handover date?",
    field_97: "What is the year of the practical completion or handover date?",
    field_98: "Was the household re-housed under a local authority nominations agreement?",
    field_99: "Was the buyer a private registered provider, housing association or local authority tenant immediately before this sale?",
    field_100: "How many bedrooms did the buyer's previous property have?",

    field_101: "What was the type of the buyer's previous property?",
    field_102: "What was the rent type of the buyer's previous property?",
    field_103: "What was the full purchase price?",
    field_104: "What was the initial percentage equity stake purchased?",
    field_105: "Was a mortgage used for the purchase of this property? - Shared ownership",
    field_106: "What is the mortgage amount?",
    field_107: "What is the name of the mortgage lender? - Shared ownership",
    field_108: "If 'other', what is the name of the mortgage lender?",
    field_109: "What is the length of the mortgage in years? - Shared ownership",
    field_110: "Does this include any extra borrowing?",

    field_111: "How much was the cash deposit paid on the property?",
    field_112: "How much cash discount was given through Social Homebuy?",
    field_113: "What is the basic monthly rent?",
    field_114: "What are the total monthly leasehold charges for the property?",
    field_115: "How long have the buyers been living in the property before the purchase? - Discounted ownership",
    field_116: "What was the full purchase price?",
    field_117: "What was the amount of any loan, grant, discount or subsidy given?",
    field_118: "What was the percentage discount?",
    field_119: "Was a mortgage used for the purchase of this property? - Discounted ownership",
    field_120: "What is the mortgage amount?",

    field_121: "What is the name of the mortgage lender? - Discounted ownership",
    field_122: "If 'other', what is the name of the mortgage lender?",
    field_123: "What is the length of the mortgage in years? - Discounted ownership",
    field_124: "Does this include any extra borrowing?",
    field_125: "How much was the cash deposit paid on the property?",
    field_126: "What are the total monthly leasehold charges for the property?",
    field_127: "What is the full purchase price?",
    field_128: "Was a mortgage used for the purchase of this property? - Outright sale",
    field_129: "What is the mortgage amount?",
    field_130: "What is the name of the mortgage lender? - Outright sale",

    field_131: "If 'other', what is the name of the mortgage lender?",
    field_132: "What is the length of the mortgage in years? - Outright sale",
    field_133: "Does this include any extra borrowing?",
    field_134: "How much was the cash deposit paid on the property?",
    field_135: "What are the total monthly leasehold charges for the property?",
  }.freeze

  attribute :bulk_upload
  attribute :block_log_creation, :boolean, default: -> { false }

  attribute :field_blank

  attribute :field_1, :string
  attribute :field_2, :string
  attribute :field_3, :integer
  attribute :field_4, :integer
  attribute :field_5, :integer
  attribute :field_6, :string
  attribute :field_7, :integer
  attribute :field_8, :integer
  attribute :field_9, :integer
  attribute :field_10, :integer

  attribute :field_11, :string
  attribute :field_12, :integer
  attribute :field_13, :integer
  attribute :field_14, :integer
  attribute :field_15, :integer
  attribute :field_16, :integer
  attribute :field_17, :integer
  attribute :field_18, :integer
  attribute :field_19, :string
  attribute :field_20, :string

  attribute :field_21, :string
  attribute :field_22, :string
  attribute :field_23, :string
  attribute :field_24, :string
  attribute :field_25, :string
  attribute :field_26, :string
  attribute :field_27, :integer
  attribute :field_28, :integer
  attribute :field_29, :integer
  attribute :field_30, :string

  attribute :field_31, :string
  attribute :field_32, :integer
  attribute :field_33, :integer
  attribute :field_34, :string
  attribute :field_35, :integer
  attribute :field_36, :integer
  attribute :field_37, :string
  attribute :field_38, :string
  attribute :field_39, :string
  attribute :field_40, :integer

  attribute :field_41, :integer
  attribute :field_42, :string
  attribute :field_43, :integer
  attribute :field_44, :integer
  attribute :field_45, :integer
  attribute :field_46, :string
  attribute :field_47, :string
  attribute :field_48, :string
  attribute :field_49, :integer
  attribute :field_50, :string

  attribute :field_51, :string
  attribute :field_52, :string
  attribute :field_53, :integer
  attribute :field_54, :string
  attribute :field_55, :string
  attribute :field_56, :string
  attribute :field_57, :integer
  attribute :field_58, :string
  attribute :field_59, :string
  attribute :field_60, :string

  attribute :field_61, :integer
  attribute :field_62, :integer
  attribute :field_63, :integer
  attribute :field_64, :string
  attribute :field_65, :string
  attribute :field_66, :string
  attribute :field_67, :integer
  attribute :field_68, :integer
  attribute :field_69, :integer
  attribute :field_70, :integer

  attribute :field_71, :integer
  attribute :field_72, :string
  attribute :field_73, :integer
  attribute :field_74, :integer
  attribute :field_75, :integer
  attribute :field_76, :integer
  attribute :field_77, :integer
  attribute :field_78, :string
  attribute :field_79, :integer
  attribute :field_80, :string

  attribute :field_81, :integer
  attribute :field_82, :integer
  attribute :field_83, :string
  attribute :field_84, :integer
  attribute :field_85, :integer
  attribute :field_86, :integer
  attribute :field_87, :integer
  attribute :field_88, :integer
  attribute :field_89, :integer
  attribute :field_90, :integer

  attribute :field_91, :integer
  attribute :field_92, :integer
  attribute :field_93, :integer
  attribute :field_94, :integer
  attribute :field_95, :integer
  attribute :field_96, :integer
  attribute :field_97, :integer
  attribute :field_98, :integer
  attribute :field_99, :integer
  attribute :field_100, :integer

  attribute :field_101, :integer
  attribute :field_102, :integer
  attribute :field_103, :integer
  attribute :field_104, :integer
  attribute :field_105, :integer
  attribute :field_106, :integer
  attribute :field_107, :integer
  attribute :field_108, :string
  attribute :field_109, :integer
  attribute :field_110, :integer

  attribute :field_111, :integer
  attribute :field_112, :integer
  attribute :field_113, :decimal
  attribute :field_114, :decimal
  attribute :field_115, :integer
  attribute :field_116, :integer
  attribute :field_117, :integer
  attribute :field_118, :integer
  attribute :field_119, :integer
  attribute :field_120, :integer

  attribute :field_121, :integer
  attribute :field_122, :string
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
  attribute :field_135, :integer

  validates :field_3,
            presence: {
              message: I18n.t("validations.not_answered", question: "sale completion date (day)."),
              category: :setup,
            },
            on: :after_log

  validates :field_4,
            presence: {
              message: I18n.t("validations.not_answered", question: "sale completion date (month)."),
              category: :setup,
            }, on: :after_log

  validates :field_5,
            presence: {
              message: I18n.t("validations.not_answered", question: "sale completion date (year)."),
              category: :setup,
            },
            format: {
              with: /\A\d{2}\z/,
              message: I18n.t("validations.setup.saledate.year_not_two_digits"),
              category: :setup,
              if: proc { field_5.present? },
            }, on: :after_log

  validates :field_7,
            presence: {
              message: I18n.t("validations.not_answered", question: "purchase made under ownership scheme."),
              category: :setup,
            },
            on: :after_log

  validates :field_8,
            inclusion: {
              in: [2, 30, 18, 16, 24, 28, 31, 32],
              if: proc { field_8.present? },
              category: :setup,
              question: QUESTIONS[:field_8].downcase,
            },
            on: :before_log

  validates :field_8,
            presence: {
              message: I18n.t("validations.not_answered", question: "type of shared ownership sale."),
              category: :setup,
              if: :shared_ownership?,
            },
            on: :after_log

  validates :field_9,
            inclusion: {
              in: [8, 14, 27, 9, 29, 21, 22],
              if: proc { field_9.present? },
              category: :setup,
              question: QUESTIONS[:field_9].downcase,
            },
            on: :before_log

  validates :field_9,
            presence: {
              message: I18n.t("validations.not_answered", question: "type of discounted ownership sale."),
              category: :setup,
              if: :discounted_ownership?,
            },
            on: :after_log

  validates :field_10,
            inclusion: {
              in: [10, 12],
              if: proc { field_10.present? },
              category: :setup,
              question: QUESTIONS[:field_10].downcase,
            },
            on: :before_log

  validates :field_10,
            presence: {
              message: I18n.t("validations.not_answered", question: "type of outright sale."),
              category: :setup,
              if: :outright_sale?,
            },
            on: :after_log

  validates :field_11,
            presence: {
              message: I18n.t("validations.not_answered", question: "type of outright sale."),
              category: :setup,
              if: proc { field_10 == 12 },
            },
            on: :after_log

  validates :field_12,
            inclusion: {
              in: [1, 2],
              if: proc { outright_sale? && field_12.present? },
              category: :setup,
              question: QUESTIONS[:field_12].downcase,
            },
            on: :before_log

  validates :field_12,
            presence: {
              message: I18n.t("validations.not_answered", question: "company buyer."),
              category: :setup,
              if: :outright_sale?,
            },
            on: :after_log

  validates :field_13,
            inclusion: {
              in: [1, 2],
              if: proc { outright_sale? && field_13.present? },
              category: :setup,
              question: QUESTIONS[:field_13].downcase,
            },
            on: :before_log

  validates :field_13,
            presence: {
              message: I18n.t("validations.not_answered", question: "buyers living in property."),
              category: :setup,
              if: :outright_sale?,
            },
            on: :after_log

  validates :field_14,
            presence: {
              message: I18n.t("validations.not_answered", question: "joint purchase."),
              category: :setup,
              if: :joint_purchase_asked?,
            },
            on: :after_log

  validates :field_15,
            presence: {
              message: I18n.t("validations.not_answered", question: "more than 2 joint buyers."),
              category: :setup,
              if: :joint_purchase?,
            },
            on: :after_log

  validate :validate_buyer1_economic_status, on: :before_log
  validate :validate_nulls, on: :after_log
  validate :validate_valid_radio_option, on: :before_log

  validate :validate_owning_org_data_given, on: :after_log
  validate :validate_owning_org_exists, on: :after_log
  validate :validate_owning_org_owns_stock, on: :after_log
  validate :validate_owning_org_permitted, on: :after_log

  validate :validate_assigned_to_exists, on: :after_log
  validate :validate_assigned_to_related, on: :after_log
  validate :validate_managing_org_related, on: :after_log
  validate :validate_relevant_collection_window, on: :after_log
  validate :validate_incomplete_soft_validations, on: :after_log

  validate :validate_uprn_exists_if_any_key_address_fields_are_blank, on: :after_log
  validate :validate_address_fields, on: :after_log
  validate :validate_if_log_already_exists, on: :after_log, if: -> { FeatureToggle.bulk_upload_duplicate_log_check_enabled? }

  validate :validate_data_protection_answered, on: :after_log

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
      .reject(&:blank?)
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
        next if errors.include?(field)

        question = log.form.get_question(error.attribute, log)

        if question.present? && setup_question?(question)
          errors.add(field, error.message, category: :setup)
        else
          errors.add(field, error.message)
        end
      end
    end

    errors.blank?
  end

  def block_log_creation?
    block_log_creation
  end

  def inspect
    "#<BulkUpload::Sales::Year2023::RowParser:#{object_id}>"
  end

  def log_already_exists?
    @log_already_exists ||= SalesLog
      .where(status: %w[not_started in_progress completed])
      .exists?(duplicate_check_fields.index_with { |field| log.public_send(field) })
  end

  def purchaser_code
    field_6
  end

  def spreadsheet_duplicate_hash
    attributes.slice(
      "field_1",  # owning org
      "field_3",  # saledate
      "field_4",  # saledate
      "field_5",  # saledate
      "field_6",  # purchaser_code
      "field_24", # postcode
      "field_25", # postcode
      "field_30", # age1
      "field_31", # sex1
      "field_35", # ecstat1
    )
  end

  def add_duplicate_found_in_spreadsheet_errors
    spreadsheet_duplicate_hash.each_key do |field|
      errors.add(field, :spreadsheet_dupe, category: :setup)
    end
  end

private

  def validate_data_protection_answered
    unless field_29 == 1
      errors.add(:field_29, I18n.t("validations.not_answered", question: "Data Protection question."), category: :setup)
    end
  end

  def prevtenbuy2
    case field_72
    when "R"
      0
    else
      field_72
    end
  end

  def infer_buyer2_ethnic_group_from_ethnic
    case field_40
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
    else
      field_40
    end
  end

  def validate_uprn_exists_if_any_key_address_fields_are_blank
    if field_19.blank? && (field_20.blank? || field_22.blank?)
      errors.add(:field_19, I18n.t("validations.not_answered", question: "UPRN."), category: :not_answered)
    end
  end

  def validate_address_fields
    if field_19.blank? || log.errors.attribute_names.include?(:uprn)
      if field_20.blank?
        errors.add(:field_20, I18n.t("validations.not_answered", question: "address line 1."), category: :not_answered)
      end

      if field_22.blank?
        errors.add(:field_22, I18n.t("validations.not_answered", question: "town or city."), category: :not_answered)
      end
    end
  end

  def shared_ownership?
    field_7 == 1
  end

  def discounted_ownership?
    field_7 == 2
  end

  def outright_sale?
    field_7 == 3
  end

  def joint_purchase?
    field_14 == 1
  end

  def joint_purchase_asked?
    shared_ownership? || discounted_ownership? || field_12 == 2
  end

  def field_mapping_for_errors
    {
      purchid: %i[field_6],
      saledate: %i[field_3 field_4 field_5],
      noint: %i[field_28],
      age1_known: %i[field_30],
      age1: %i[field_30],
      age2_known: %i[field_38],
      age2: %i[field_38],
      age3_known: %i[field_47],
      age3: %i[field_47],
      age4_known: %i[field_51],
      age4: %i[field_51],
      age5_known: %i[field_55],
      age5: %i[field_55],
      age6_known: %i[field_59],
      age6: %i[field_59],
      sex1: %i[field_31],
      sex2: %i[field_39],
      sex3: %i[field_48],

      sex4: %i[field_52],
      sex5: %i[field_56],
      sex6: %i[field_60],
      relat2: %i[field_37],
      relat3: %i[field_46],
      relat4: %i[field_50],
      relat5: %i[field_54],
      relat6: %i[field_58],

      ecstat1: %i[field_35],
      ecstat2: %i[field_43],
      ecstat3: %i[field_49],

      ecstat4: %i[field_53],
      ecstat5: %i[field_57],
      ecstat6: %i[field_61],
      ethnic_group: %i[field_32],
      ethnic: %i[field_32],
      national: %i[field_33],
      income1nk: %i[field_78],
      income1: %i[field_78],
      income2nk: %i[field_80],
      income2: %i[field_80],
      inc1mort: %i[field_79],
      inc2mort: %i[field_81],
      savingsnk: %i[field_83],
      savings: %i[field_83],
      prevown: %i[field_84],
      prevten: %i[field_62],
      prevloc: %i[field_66],
      previous_la_known: %i[field_66],
      ppcodenk: %i[field_63],
      ppostcode_full: %i[field_64 field_65],
      pregyrha: %i[field_67],
      pregla: %i[field_69],
      pregghb: %i[field_70],
      pregother: %i[field_68],
      disabled: %i[field_76],

      wheel: %i[field_77],
      beds: %i[field_16],
      proptype: %i[field_17],
      builtype: %i[field_18],
      la_known: %i[field_26],
      la: %i[field_26],

      is_la_inferred: %i[field_26],
      pcodenk: %i[field_24 field_25],
      postcode_full: %i[field_24 field_25],
      wchair: %i[field_27],

      type: %i[field_8 field_9 field_10 field_7],
      resale: %i[field_91],
      hodate: %i[field_95 field_96 field_97],
      exdate: %i[field_92 field_93 field_94],

      lanomagr: %i[field_98],
      frombeds: %i[field_100],
      fromprop: %i[field_101],
      value: %i[field_103 field_116 field_127],
      equity: %i[field_104],
      mortgage: %i[field_106 field_120 field_129],
      extrabor: %i[field_110 field_124 field_133],
      deposit: %i[field_111 field_125 field_134],
      cashdis: %i[field_112],
      mrent: %i[field_113],

      has_mscharge: %i[field_114 field_126 field_135],
      mscharge: %i[field_114 field_126 field_135],
      grant: %i[field_117],
      discount: %i[field_118],
      othtype: %i[field_11],
      owning_organisation_id: %i[field_1],
      assigned_to: %i[field_2],
      hhregres: %i[field_73],
      hhregresstill: %i[field_74],
      armedforcesspouse: %i[field_75],

      mortgagelender: %i[field_107 field_121 field_130],
      mortgagelenderother: %i[field_108 field_122 field_131],

      hb: %i[field_82],
      mortlen: %i[field_109 field_123 field_132],
      proplen: %i[field_115 field_86],

      jointmore: %i[field_15],
      staircase: %i[field_87],
      privacynotice: %i[field_29],
      ownershipsch: %i[field_7],
      companybuy: %i[field_12],
      buylivein: %i[field_13],

      jointpur: %i[field_14],
      buy1livein: %i[field_36],
      buy2livein: %i[field_44],
      hholdcount: %i[field_45],
      stairbought: %i[field_88],
      stairowned: %i[field_89],
      socprevten: %i[field_102],
      mortgageused: [mortgageused_field],
      soctenant: %i[field_99],

      uprn: %i[field_19],
      address_line1: %i[field_20],
      address_line2: %i[field_21],
      town_or_city: %i[field_22],
      county: %i[field_23],

      ethnic_group2: %i[field_40],
      ethnicbuy2: %i[field_40],
      nationalbuy2: %i[field_41],

      buy2living: %i[field_71],
      prevtenbuy2: %i[field_72],

      prevshared: %i[field_85],

      staircasesale: %i[field_90],
    }
  end

  def attributes_for_log
    attributes = {}

    attributes["purchid"] = purchaser_code
    attributes["saledate"] = saledate
    attributes["noint"] = field_28

    attributes["age1_known"] = age1_known?
    attributes["age1"] = field_30 if attributes["age1_known"]&.zero? && field_30&.match(/\A\d{1,3}\z|\AR\z/)

    attributes["age2_known"] = age2_known?
    attributes["age2"] = field_38 if attributes["age2_known"]&.zero? && field_38&.match(/\A\d{1,3}\z|\AR\z/)

    attributes["age3_known"] = age3_known?
    attributes["age3"] = field_47 if attributes["age3_known"]&.zero? && field_47&.match(/\A\d{1,3}\z|\AR\z/)

    attributes["age4_known"] = age4_known?
    attributes["age4"] = field_51 if attributes["age4_known"]&.zero? && field_51&.match(/\A\d{1,3}\z|\AR\z/)

    attributes["age5_known"] = age5_known?
    attributes["age5"] = field_55 if attributes["age5_known"]&.zero? && field_55&.match(/\A\d{1,3}\z|\AR\z/)

    attributes["age6_known"] = age6_known?
    attributes["age6"] = field_59 if attributes["age6_known"]&.zero? && field_59&.match(/\A\d{1,3}\z|\AR\z/)

    attributes["sex1"] = field_31
    attributes["sex2"] = field_39
    attributes["sex3"] = field_48
    attributes["sex4"] = field_52
    attributes["sex5"] = field_56
    attributes["sex6"] = field_60

    attributes["relat2"] = field_37
    attributes["relat3"] = field_46
    attributes["relat4"] = field_50
    attributes["relat5"] = field_54
    attributes["relat6"] = field_58

    attributes["ecstat1"] = field_35
    attributes["ecstat2"] = field_43
    attributes["ecstat3"] = field_49
    attributes["ecstat4"] = field_53
    attributes["ecstat5"] = field_57
    attributes["ecstat6"] = field_61

    attributes["details_known_2"] = details_known?(2)
    attributes["details_known_3"] = details_known?(3)
    attributes["details_known_4"] = details_known?(4)
    attributes["details_known_5"] = details_known?(5)
    attributes["details_known_6"] = details_known?(6)

    attributes["ethnic_group"] = ethnic_group_from_ethnic
    attributes["ethnic"] = field_32
    attributes["national"] = field_33

    attributes["income1nk"] = field_78 == "R" ? 1 : 0
    attributes["income1"] = field_78.to_i if attributes["income1nk"]&.zero? && field_78&.match(/\A\d+\z/)

    attributes["income2nk"] = field_80 == "R" ? 1 : 0
    attributes["income2"] = field_80.to_i if attributes["income2nk"]&.zero? && field_80&.match(/\A\d+\z/)

    attributes["inc1mort"] = field_79
    attributes["inc2mort"] = field_81

    attributes["savingsnk"] = field_83 == "R" ? 1 : 0
    attributes["savings"] = field_83.to_i if attributes["savingsnk"]&.zero? && field_83&.match(/\A\d+\z/)
    attributes["prevown"] = field_84

    attributes["prevten"] = field_62
    attributes["prevloc"] = field_66
    attributes["previous_la_known"] = previous_la_known
    attributes["ppcodenk"] = previous_postcode_known
    attributes["ppostcode_full"] = ppostcode_full

    attributes["pregyrha"] = field_67
    attributes["pregla"] = field_69
    attributes["pregghb"] = field_70
    attributes["pregother"] = field_68
    attributes["pregblank"] = no_buyer_organisation

    attributes["disabled"] = field_76
    attributes["wheel"] = field_77
    attributes["beds"] = field_16
    attributes["proptype"] = field_17
    attributes["builtype"] = field_18
    attributes["la_known"] = field_26.present? ? 1 : 0
    attributes["la"] = field_26
    attributes["is_la_inferred"] = false
    attributes["pcodenk"] = 0 if postcode_full.present?
    attributes["postcode_full"] = postcode_full
    attributes["wchair"] = field_27

    attributes["type"] = sale_type
    attributes["resale"] = field_91

    attributes["hodate"] = hodate
    attributes["exdate"] = exdate

    attributes["lanomagr"] = field_98

    attributes["frombeds"] = field_100
    attributes["fromprop"] = field_101

    attributes["value"] = value
    attributes["equity"] = field_104
    attributes["mortgage"] = mortgage
    attributes["extrabor"] = extrabor
    attributes["deposit"] = deposit

    attributes["cashdis"] = field_112
    attributes["mrent"] = field_113
    attributes["mscharge"] = mscharge if mscharge&.positive?
    attributes["has_mscharge"] = attributes["mscharge"].present? ? 1 : 0
    attributes["grant"] = field_117
    attributes["discount"] = field_118

    attributes["othtype"] = field_11

    attributes["owning_organisation"] = owning_organisation
    attributes["managing_organisation"] = managing_organisation
    attributes["assigned_to"] = assigned_to || bulk_upload.user
    attributes["created_by"] = bulk_upload.user
    attributes["hhregres"] = field_73
    attributes["hhregresstill"] = field_74
    attributes["armedforcesspouse"] = field_75

    attributes["mortgagelender"] = mortgagelender
    attributes["mortgagelenderother"] = mortgagelenderother

    attributes["hb"] = field_82

    attributes["mortlen"] = mortlen

    attributes["proplen"] = proplen if proplen&.positive?
    attributes["proplen_asked"] = attributes["proplen"]&.present? ? 0 : 1
    attributes["jointmore"] = field_15
    attributes["staircase"] = field_87
    attributes["privacynotice"] = field_29
    attributes["ownershipsch"] = field_7
    attributes["companybuy"] = field_12
    attributes["buylivein"] = field_13
    attributes["jointpur"] = field_14
    attributes["buy1livein"] = field_36
    attributes["buy2livein"] = field_44
    attributes["hholdcount"] = field_45
    attributes["stairbought"] = field_88
    attributes["stairowned"] = field_89
    attributes["socprevten"] = field_102
    attributes["mortgageused"] = mortgageused

    attributes["uprn"] = field_19
    attributes["uprn_known"] = field_19.present? ? 1 : 0
    attributes["uprn_confirmed"] = 1 if field_19.present?
    attributes["skip_update_uprn_confirmed"] = true
    attributes["address_line1"] = field_20
    attributes["address_line2"] = field_21
    attributes["town_or_city"] = field_22
    attributes["county"] = field_23

    attributes["ethnic_group2"] = infer_buyer2_ethnic_group_from_ethnic
    attributes["ethnicbuy2"] = field_40
    attributes["nationalbuy2"] = field_41

    attributes["buy2living"] = field_71
    attributes["prevtenbuy2"] = prevtenbuy2

    attributes["prevshared"] = field_85

    attributes["staircasesale"] = field_90

    attributes["soctenant"] = field_99

    attributes
  end

  def saledate
    Date.new(field_5 + 2000, field_4, field_3) if field_5.present? && field_4.present? && field_3.present?
  rescue Date::Error
    Date.new
  end

  def hodate
    Date.new(field_97 + 2000, field_96, field_95) if field_97.present? && field_96.present? && field_95.present?
  rescue Date::Error
    Date.new
  end

  def exdate
    Date.new(field_94 + 2000, field_93, field_92) if field_94.present? && field_93.present? && field_92.present?
  rescue Date::Error
    Date.new
  end

  def age1_known?
    return 1 if field_30 == "R"

    0
  end

  [
    { person: 2, field: :field_38 },
    { person: 3, field: :field_47 },
    { person: 4, field: :field_51 },
    { person: 5, field: :field_55 },
    { person: 6, field: :field_59 },
  ].each do |hash|
    define_method("age#{hash[:person]}_known?") do
      return 1 if public_send(hash[:field]) == "R"
      return 0 if send("person_#{hash[:person]}_present?")
    end
  end

  def person_2_present?
    field_38.present? || field_39.present? || field_37.present?
  end

  def person_3_present?
    field_47.present? || field_48.present? || field_46.present?
  end

  def person_4_present?
    field_51.present? || field_52.present? || field_50.present?
  end

  def person_5_present?
    field_55.present? || field_56.present? || field_54.present?
  end

  def person_6_present?
    field_59.present? || field_60.present? || field_58.present?
  end

  def details_known?(person_n)
    send("person_#{person_n}_present?") ? 1 : 2
  end

  def ethnic_group_from_ethnic
    return nil if field_32.blank?

    case field_32
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
    "#{field_24} #{field_25}" if field_24 && field_25
  end

  def ppostcode_full
    "#{field_64} #{field_65}" if field_64 && field_65
  end

  def sale_type
    return field_8 if shared_ownership?
    return field_9 if discounted_ownership?
    return field_10 if outright_sale?
  end

  def value
    return field_103 if shared_ownership?
    return field_116 if discounted_ownership?
    return field_127 if outright_sale?
  end

  def mortgage
    return field_106 if shared_ownership?
    return field_120 if discounted_ownership?
    return field_129 if outright_sale?
  end

  def extrabor
    return field_110 if shared_ownership?
    return field_124 if discounted_ownership?
    return field_133 if outright_sale?
  end

  def deposit
    return field_111 if shared_ownership?
    return field_125 if discounted_ownership?
    return field_134 if outright_sale?
  end

  def mscharge
    return field_114 if shared_ownership?
    return field_126 if discounted_ownership?
    return field_135 if outright_sale?
  end

  def mortgagelender
    return field_107 if shared_ownership?
    return field_121 if discounted_ownership?
    return field_130 if outright_sale?
  end

  def mortgagelenderother
    return field_108 if shared_ownership?
    return field_122 if discounted_ownership?
    return field_131 if outright_sale?
  end

  def mortlen
    return field_109 if shared_ownership?
    return field_123 if discounted_ownership?
    return field_132 if outright_sale?
  end

  def proplen
    return field_86 if shared_ownership?
    return field_115 if discounted_ownership?
  end

  def mortgageused
    return field_105 if shared_ownership?
    return field_119 if discounted_ownership?
    return field_128 if outright_sale?
  end

  def mortgageused_field
    return :field_105 if shared_ownership?
    return :field_119 if discounted_ownership?
    return :field_128 if outright_sale?
  end

  def owning_organisation
    @owning_organisation ||= Organisation.find_by_id_on_multiple_fields(field_1)
  end

  def assigned_to
    @assigned_to ||= User.where("lower(email) = ?", field_2&.downcase).first
  end

  def previous_la_known
    field_66.present? ? 1 : 0
  end

  def previous_postcode_known
    return 1 if field_63 == 2

    0 if field_63 == 1
  end

  def no_buyer_organisation
    [field_67, field_68, field_69, field_70].all?(&:blank?) ? 1 : nil?
  end

  def block_log_creation!
    self.block_log_creation = true
  end

  def questions
    @questions ||= log.form.subsections.flat_map { |ss| ss.applicable_questions(log) }
  end

  def duplicate_check_fields
    %w[
      saledate
      age1
      sex1
      ecstat1
      owning_organisation
      postcode_full
      purchid
    ]
  end

  def validate_owning_org_data_given
    if field_1.blank?
      block_log_creation!

      if errors[:field_1].blank?
        errors.add(:field_1, "The owning organisation code is incorrect.", category: :setup)
      end
    end
  end

  def validate_owning_org_exists
    if owning_organisation.nil?
      block_log_creation!

      if errors[:field_1].blank?
        errors.add(:field_1, "The owning organisation code is incorrect.", category: :setup)
      end
    end
  end

  def validate_owning_org_owns_stock
    if owning_organisation && !owning_organisation.holds_own_stock?
      block_log_creation!

      if errors[:field_1].blank?
        errors.add(:field_1, "The owning organisation code provided is for an organisation that does not own stock.", category: :setup)
      end
    end
  end

  def validate_owning_org_permitted
    if owning_organisation && !bulk_upload.user.organisation.affiliated_stock_owners.include?(owning_organisation)
      block_log_creation!

      if errors[:field_1].blank?
        errors.add(:field_1, "You do not have permission to add logs for this owning organisation.", category: :setup)
      end
    end
  end

  def validate_assigned_to_exists
    return if field_2.blank?

    unless assigned_to
      errors.add(:field_2, "User with the specified email could not be found.")
    end
  end

  def validate_assigned_to_related
    return unless assigned_to
    return if assigned_to.organisation == owning_organisation || assigned_to.organisation == managing_organisation
    return if assigned_to.organisation == owning_organisation&.absorbing_organisation || assigned_to.organisation == managing_organisation&.absorbing_organisation

    block_log_creation!
    errors.add(:field_2, "User must be related to owning organisation or managing organisation.", category: :setup)
  end

  def managing_organisation
    return owning_organisation if assigned_to&.organisation&.absorbed_organisations&.include?(owning_organisation)

    assigned_to&.organisation || bulk_upload.user.organisation
  end

  def validate_managing_org_related
    if owning_organisation && managing_organisation && !owning_organisation.can_be_managed_by?(organisation: managing_organisation)
      block_log_creation!

      if errors[:field_2].blank?
        errors.add(:field_2, "This user belongs to an organisation that does not have a relationship with the owning organisation.", category: :setup)
      end
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
          unless errors.any? { |e| fields.include?(e.attribute) }
            errors.add(field, I18n.t("validations.not_answered", question: downcase(question.error_display_label)), category: :setup)
          end
        end
      else
        fields.each do |field|
          unless errors.any? { |e| fields.include?(e.attribute) }
            errors.add(field, I18n.t("validations.not_answered", question: downcase(question.error_display_label)), category: :not_answered)
          end
        end
      end
    end
  end

  def validate_valid_radio_option
    log.attributes.each do |question_id, _v|
      question = log.form.get_question(question_id, log)

      next if question_id == "type"

      next unless question&.type == "radio"
      next if log[question_id].blank? || question.answer_options.key?(log[question_id].to_s) || !question.page.routed_to?(log, nil)

      fields = field_mapping_for_errors[question_id.to_sym] || []

      if setup_question?(question)
        fields.each do |field|
          if errors[field].none?
            block_log_creation!
            errors.add(field, I18n.t("validations.invalid_option", question: format_ending(downcase(QUESTIONS[field]))), category: :setup)
          end
        end
      else
        fields.each do |field|
          unless errors.any? { |e| fields.include?(e.attribute) }
            errors.add(field, I18n.t("validations.invalid_option", question: format_ending(downcase(QUESTIONS[field]))))
          end
        end
      end
    end
  end

  def validate_relevant_collection_window
    return if saledate.blank? || bulk_upload.form.blank?
    return if errors.key?(:field_3) || errors.key?(:field_4) || errors.key?(:field_5)

    unless bulk_upload.form.valid_start_date_for_form?(saledate)
      errors.add(:field_3, I18n.t("validations.date.outside_collection_window", year_combo: bulk_upload.year_combo, start_year: bulk_upload.year, end_year: bulk_upload.end_year), category: :setup)
      errors.add(:field_4, I18n.t("validations.date.outside_collection_window", year_combo: bulk_upload.year_combo, start_year: bulk_upload.year, end_year: bulk_upload.end_year), category: :setup)
      errors.add(:field_5, I18n.t("validations.date.outside_collection_window", year_combo: bulk_upload.year_combo, start_year: bulk_upload.year, end_year: bulk_upload.end_year), category: :setup)
    end
  end

  def validate_if_log_already_exists
    if log_already_exists?
      error_message = "This is a duplicate log."

      errors.add(:field_1, error_message) # Owning org
      errors.add(:field_3, error_message) # Sale completion date
      errors.add(:field_4, error_message) # Sale completion date
      errors.add(:field_5, error_message) # Sale completion date
      errors.add(:field_24, error_message) # Postcode
      errors.add(:field_25, error_message) # Postcode
      errors.add(:field_30, error_message) # Buyer 1 age
      errors.add(:field_31, error_message) # Buyer 1 gender
      errors.add(:field_35, error_message) # Buyer 1 working situation
      errors.add(:field_6, error_message) # Purchaser code
    end
  end

  def validate_incomplete_soft_validations
    routed_to_soft_validation_questions = log.form.questions.filter { |q| q.type == "interruption_screen" && q.page.routed_to?(log, nil) }.compact
    routed_to_soft_validation_questions.each do |question|
      next if question.completed?(log)

      question.page.interruption_screen_question_ids.each do |interruption_screen_question_id|
        next if log.form.questions.none? { |q| q.id == interruption_screen_question_id && q.page.routed_to?(log, nil) }

        field_mapping_for_errors[interruption_screen_question_id.to_sym]&.each do |field|
          if errors.none? { |e| e.options[:category] == :soft_validation && field_mapping_for_errors[interruption_screen_question_id.to_sym].include?(e.attribute) }
            error_message = [display_title_text(question.page.title_text, log), display_informative_text(question.page.informative_text, log)].reject(&:empty?).join(" ")
            errors.add(field, message: error_message, category: :soft_validation)
          end
        end
      end
    end
  end

  def validate_buyer1_economic_status
    if field_35 == 9
      errors.add(:field_35, "Buyer 1 cannot be a child under 16.")
    end
  end

  def downcase(text)
    downcase_first_letter(text)
  end
end
