class BulkUpload::Sales::Year2026::RowParser
  include ActiveModel::Model
  include ActiveModel::Attributes
  include InterruptionScreenHelper
  include FormattingHelper

  QUESTIONS = {
    field_1: "What is the sale completion date? - day DD",
    field_2: "What is the sale completion date? - month MM",
    field_3: "What is the sale completion date? - year YY",
    field_4: "Which organisation owned this property before the sale?",
    field_5: "Which organisation is reporting this sale?",
    field_6: "What is the CORE username of the account this sales log should be assigned to?",
    field_7: "What is the purchaser code?",
    field_8: "Is this a shared ownership or discounted ownership sale?",
    field_9: "What is the type of shared ownership sale?",
    field_10: "Is this a staircasing transaction?",
    field_11: "What is the type of discounted ownership sale?",
    field_12: "Is this a joint purchase?",
    field_13: "Are there more than 2 joint buyers of this property?",
    field_14: "Did you interview the buyer to answer these questions?",
    field_15: "Has the buyer seen or been given access to the MHCLG privacy notice?",

    field_16: "If known, enter this property’s UPRN",
    field_17: "Address Line 1",
    field_18: "Address Line 2",
    field_19: "Town or city",
    field_20: "County",
    field_21: "Part 1 of the property's postcode",
    field_22: "Part 2 of the property's postcode",
    field_23: "What is the property's local authority?",
    field_24: "What type of unit is the property?",
    field_25: "What is the building height classification?",
    field_26: "How many bedrooms does the property have?",
    field_27: "Which type of building is the property?",
    field_28: "Is the property built or adapted to wheelchair-user standards?",

    field_29: "What is buyer 1’s age?",
    field_30: "What is buyer 1's sex?",
    field_31: "Is the gender buyer 1 identifies with the same as their sex registered at birth?",
    field_32: "If 'No', enter buyer 1's gender identity",
    field_33: "Which of the following best describes buyer 1's ethnic background?",
    field_34: "What is buyer 1's nationality?",
    field_35: "Which of these best describes buyer 1’s working situation?",
    field_36: "Will buyer 1 live in the property?",
    field_37: "Is buyer 2 or person 2 the partner of buyer 1?",
    field_38: "What is buyer 2's or person 2's age?",
    field_39: "What is buyer 2 or person 2's sex?",
    field_40: "Is the gender buyer 2 or person 2 identifies with the same as their sex registered at birth?",
    field_41: "If 'No', enter buyer 2 or person 2's gender identity",
    field_42: "Which of the following best describes buyer 2 or person 2's ethnic background?",
    field_43: "What is buyer 2 or person 2's nationality?",
    field_44: "Which of these best describes buyer 2 or person 2’s working situation?",
    field_45: "Will buyer 2 or person 2 live in the property?",
    field_46: "In total, how many people live in the property?",

    field_47: "Is person 3 the partner of buyer 1?",
    field_48: "What is person 3's age?",
    field_49: "What is person 3's sex?",
    field_50: "Is the gender person 3's identifies with the same as their sex registered at birth?",
    field_51: "If 'No', enter person 3's gender identity",
    field_52: "Which of these best describes person 3’s working situation?",
    field_53: "Is person 4 the partner of buyer 1?",
    field_54: "What is person 4's age?",
    field_55: "What is person 4's sex?",
    field_56: "Is the gender person 4's identifies with the same as their sex registered at birth?",
    field_57: "If 'No', enter person 4's gender identity",
    field_58: "Which of these best describes person 4’s working situation?",
    field_59: "Is person 5 the partner of buyer 1?",
    field_60: "What is person 5's age?",
    field_61: "What is person 5's sex?",
    field_62: "Is the gender person 5's identifies with the same as their sex registered at birth?",
    field_63: "If 'No', enter person 5's gender identity",
    field_64: "Which of these best describes person 5’s working situation?",
    field_65: "Is person 6 the partner of buyer 1?",
    field_66: "What is person 6's age?",
    field_67: "What is person 6's sex?",
    field_68: "Is the gender person 6's identifies with the same as their sex registered at birth?",
    field_69: "If 'No', enter person 6's gender identity",
    field_70: "Which of these best describes person 6’s working situation?",
    field_71: "What was buyer 1's previous tenure?",
    field_72: "Do you know the postcode of buyer 1's last settled accommodation?",
    field_73: "Part 1 of postcode of buyer 1's last settled accommodation",
    field_74: "Part 2 of postcode of buyer 1's last settled accommodation",
    field_75: "What is the local authority of buyer 1's last settled accommodation?",
    field_76: "At the time of purchase, was buyer 2 living at the same address as buyer 1?",
    field_77: "What was buyer 2's previous tenure?",

    field_78: "Have any of the buyers ever served as a regular in the UK armed forces?",
    field_79: "Is the buyer still serving in the UK armed forces?",
    field_80: "Are any of the buyers a spouse or civil partner of a UK armed forces regular who died in service within the last 2 years?",
    field_81: "Does anyone in the household consider themselves to have a disability?",
    field_82: "Does anyone in the household use a wheelchair?",

    field_83: "What is buyer 1's annual income?",
    field_84: "Was buyer 1's income used for a mortgage application?",
    field_85: "What is buyer 2's annual income?",
    field_86: "Was buyer 2's income used for a mortgage application?",
    field_87: "Were the buyers receiving any of these housing-related benefits immediately before buying this property?",
    field_88: "What is the total amount the buyers had in savings before they paid any deposit for the property?",
    field_89: "Have any of the buyers previously owned a property?",
    field_90: "Was the previous property under shared ownership?",

    field_91: "Is this a resale?",
    field_92: "How long did the buyer(s) live in the property before purchasing it?",
    field_93: "What is the day of the practical completion or handover date? - DD",
    field_94: "What is the month of the practical completion or handover date? - MM",
    field_95: "What is the year of the practical completion or handover date? - YY",
    field_96: "How many bedrooms did the buyer's previous property have?",
    field_97: "What was the previous property type?",
    field_98: "What was the buyer’s previous tenure?",
    field_99: "What is the full purchase price?",
    field_100: "What was the initial percentage share purchased?",
    field_101: "Was a mortgage used to buy this property?",
    field_102: "What is the mortgage amount?",
    field_103: "What is the length of the mortgage?",
    field_104: "How much was the cash deposit paid on the property?",
    field_105: "How much cash discount was given through Social HomeBuy?",
    field_106: "What is the basic monthly rent?",
    field_107: "What are the total monthly service charges for the property?",
    field_108: "What are the total monthly estate management fees for the property?",

    field_109: "What percentage of the property has been bought in this staircasing transaction?",
    field_110: "What percentage of the property do the buyers now own in total?",
    field_111: "Was this transaction part of a back-to-back staircasing transaction to facilitate sale of the home on the open market?",
    field_112: "Is this the first time the buyer has engaged in staircasing in the home?",
    field_113: "What was the day of the initial purchase of a share in the property? DD",
    field_114: "What was the month of the initial purchase of a share in the property? MM",
    field_115: "What was the year of the initial purchase of a share in the property? YYYY",
    field_116: "Including this time, how many times has the shared owner engaged in staircasing in the home?",
    field_117: "What was the day of the last staircasing transaction? DD",
    field_118: "What was the month of the last staircasing transaction? MM",
    field_119: "What was the year of the last staircasing transaction? YYYY",
    field_120: "What is the full purchase price for this staircasing transaction?",
    field_121: "What was the percentage share purchased in the initial transaction?",
    field_122: "Was a mortgage used for this staircasing transaction?",
    field_123: "What was the basic monthly rent prior to staircasing?",
    field_124: "What is the basic monthly rent after staircasing?",
    field_125: "What are the monthly service charges for the property?",
    field_126: "If the service charges will change after this staircasing transaction takes places, what is the new monthly service charge amount?",

    field_127: "How long did the buyer(s) live in the property before purchasing it?",
    field_128: "What is the full purchase price?",
    field_129: "What was the amount of any loan, grant, discount or subsidy given?",
    field_130: "What was the percentage discount?",
    field_131: "Was a mortgage used to buy this property?",
    field_132: "What is the mortgage amount?",
    field_133: "What is the length of the mortgage?",
    field_134: "Does this include any extra borrowing?",
    field_135: "How much was the cash deposit paid on the property?",
    field_136: "What are the total monthly leasehold charges for the property?",
  }.freeze

  ERROR_BASE_KEY = "validations.sales.2026.bulk_upload".freeze

  CASE_INSENSITIVE_FIELDS = [
    :field_29, # Age of buyer 1
    :field_38, # Age of buyer/person 2
    :field_48, # Age of person 3
    :field_54, # Age of person 4
    :field_60, # Age of person 5
    :field_66, # Age of person 6

    :field_30, # Buyer 1's sex, as registered at birth
    :field_39, # Buyer/Person 2's sex, as registered at birth
    :field_49, # Person 3's sex, as registered at birth
    :field_55, # Person 4's sex, as registered at birth
    :field_61, # Person 5's sex, as registered at birth
    :field_67, # Person 6's sex, as registered at birth

    :field_77, # What was buyer 2’s previous tenure?

    :field_88, # What is the total amount the buyers had in savings before they paid any deposit for the property?
    :field_83, # What is buyer 1’s gross annual income?
    :field_85, # What is buyer 2’s gross annual income?

    :field_103, # What is the length of the mortgage in years? - Shared ownership
    :field_133, # What is the length of the mortgage in years? - Discounted ownership
  ].freeze

  attribute :bulk_upload
  attribute :block_log_creation, :boolean, default: -> { false }

  attribute :field_blank

  attribute :field_1, :integer
  attribute :field_2, :integer
  attribute :field_3, :integer
  attribute :field_4, :string
  attribute :field_5, :string
  attribute :field_6, :string
  attribute :field_7, :string
  attribute :field_8, :integer
  attribute :field_9, :integer
  attribute :field_10, :integer
  attribute :field_11, :integer
  attribute :field_12, :integer
  attribute :field_13, :integer
  attribute :field_14, :integer
  attribute :field_15, :integer

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

  attribute :field_29, :string
  attribute :field_30, :string
  attribute :field_31, :integer
  attribute :field_32, :string
  attribute :field_33, :integer
  attribute :field_34, :integer
  attribute :field_35, :integer
  attribute :field_36, :integer
  attribute :field_37, :integer
  attribute :field_38, :string
  attribute :field_39, :string
  attribute :field_40, :integer
  attribute :field_41, :string
  attribute :field_42, :integer
  attribute :field_43, :integer
  attribute :field_44, :integer
  attribute :field_45, :integer
  attribute :field_46, :integer

  attribute :field_47, :integer
  attribute :field_48, :string
  attribute :field_49, :string
  attribute :field_50, :integer
  attribute :field_51, :string
  attribute :field_52, :integer
  attribute :field_53, :integer
  attribute :field_54, :string
  attribute :field_55, :string
  attribute :field_56, :integer
  attribute :field_57, :string
  attribute :field_58, :integer
  attribute :field_59, :integer
  attribute :field_60, :string
  attribute :field_61, :string
  attribute :field_62, :integer
  attribute :field_63, :string
  attribute :field_64, :integer
  attribute :field_65, :integer
  attribute :field_66, :string
  attribute :field_67, :string
  attribute :field_68, :integer
  attribute :field_69, :string
  attribute :field_70, :integer

  attribute :field_71, :integer
  attribute :field_72, :integer
  attribute :field_73, :string
  attribute :field_74, :string
  attribute :field_75, :string
  attribute :field_76, :integer
  attribute :field_77, :string

  attribute :field_78, :integer
  attribute :field_79, :integer
  attribute :field_80, :integer
  attribute :field_81, :integer
  attribute :field_82, :integer

  attribute :field_83, :string
  attribute :field_84, :integer
  attribute :field_85, :string
  attribute :field_86, :integer
  attribute :field_87, :integer
  attribute :field_88, :string
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
  attribute :field_99, :decimal
  attribute :field_100, :decimal
  attribute :field_101, :integer
  attribute :field_102, :decimal
  attribute :field_103, :string
  attribute :field_104, :decimal
  attribute :field_105, :decimal
  attribute :field_106, :decimal
  attribute :field_107, :decimal
  attribute :field_108, :decimal

  attribute :field_109, :decimal
  attribute :field_110, :decimal
  attribute :field_111, :integer
  attribute :field_112, :integer
  attribute :field_113, :integer
  attribute :field_114, :integer
  attribute :field_115, :integer
  attribute :field_116, :integer
  attribute :field_117, :integer
  attribute :field_118, :integer
  attribute :field_119, :integer
  attribute :field_120, :decimal
  attribute :field_121, :decimal
  attribute :field_122, :integer
  attribute :field_123, :decimal
  attribute :field_124, :decimal
  attribute :field_125, :integer
  attribute :field_126, :decimal

  attribute :field_127, :integer
  attribute :field_128, :decimal
  attribute :field_129, :decimal
  attribute :field_130, :decimal
  attribute :field_131, :integer
  attribute :field_132, :decimal
  attribute :field_133, :string
  attribute :field_134, :integer
  attribute :field_135, :decimal
  attribute :field_136, :decimal

  validates :field_1,
            presence: {
              message: I18n.t("#{ERROR_BASE_KEY}.not_answered", question: "sale completion date (day)."),
              category: :setup,
            },
            on: :after_log

  validates :field_2,
            presence: {
              message: I18n.t("#{ERROR_BASE_KEY}.not_answered", question: "sale completion date (month)."),
              category: :setup,
            }, on: :after_log

  validates :field_3,
            presence: {
              message: I18n.t("#{ERROR_BASE_KEY}.not_answered", question: "sale completion date (year)."),
              category: :setup,
            },
            format: {
              with: /\A(\d{2}|\d{4})\z/,
              message: I18n.t("#{ERROR_BASE_KEY}.saledate.year_not_two_or_four_digits"),
              category: :setup,
              if: proc { field_3.present? },
            }, on: :after_log

  validates :field_8,
            inclusion: {
              in: [1, 2],
              if: proc { field_8.present? },
              category: :setup,
              question: QUESTIONS[:field_8].downcase,
            },
            on: :before_log

  validates :field_8,
            presence: {
              message: I18n.t("#{ERROR_BASE_KEY}.not_answered", question: "sale type."),
              category: :setup,
            },
            on: :after_log

  validates :field_9,
            inclusion: {
              in: [2, 30, 18, 16, 24, 28, 31, 32],
              if: proc { field_9.present? },
              category: :setup,
              question: QUESTIONS[:field_9].downcase,
            },
            on: :before_log

  validates :field_9,
            presence: {
              message: I18n.t("#{ERROR_BASE_KEY}.not_answered", question: "type of shared ownership sale."),
              category: :setup,
              if: :shared_ownership?,
            },
            on: :after_log

  validates :field_10,
            inclusion: {
              in: [1, 2],
              if: proc { field_10.present? },
              category: :setup,
              question: QUESTIONS[:field_10].downcase,
            },
            on: :before_log

  validates :field_10,
            presence: {
              message: I18n.t("#{ERROR_BASE_KEY}.not_answered", question: "staircasing transaction."),
              category: :setup,
              if: :shared_ownership?,
            },
            on: :after_log

  validates :field_11,
            inclusion: {
              in: [8, 9, 14, 21, 22, 29],
              if: proc { field_11.present? },
              category: :setup,
              question: QUESTIONS[:field_11].downcase,
            },
            on: :before_log

  validates :field_11,
            presence: {
              message: I18n.t("#{ERROR_BASE_KEY}.not_answered", question: "type of discounted ownership sale."),
              category: :setup,
              if: :discounted_ownership?,
            },
            on: :after_log

  validates :field_130,
            numericality: {
              message: I18n.t("#{ERROR_BASE_KEY}.numeric.within_range", field: "Percentage discount", min: "0%", max: "70%"),
              greater_than_or_equal_to: 0,
              less_than_or_equal_to: 70,
              if: :discounted_ownership?,
              allow_blank: true,
            },
            on: :before_log

  validates :field_12,
            presence: {
              message: I18n.t("#{ERROR_BASE_KEY}.not_answered", question: "joint purchase."),
              category: :setup,
              if: :joint_purchase_asked?,
            },
            on: :after_log

  validates :field_13,
            presence: {
              message: I18n.t("#{ERROR_BASE_KEY}.not_answered", question: "more than 2 joint buyers."),
              category: :setup,
              if: :joint_purchase?,
            },
            on: :after_log

  validates :field_116,
            numericality: {
              greater_than_or_equal_to: 2,
              less_than_or_equal_to: 10,
              message: I18n.t("#{ERROR_BASE_KEY}.numeric.within_range", field: "Number of staircasing transactions", min: "2", max: "10"),
              allow_blank: true,
            },
            on: :before_log

  validates :field_103,
            if: :shared_ownership?,
            format: {
              with: /\A(\d+|R)\z/,
              message: I18n.t("#{ERROR_BASE_KEY}.mortlen.invalid"),
            },
            on: :after_log

  validates :field_133,
            if: :discounted_ownership?,
            format: {
              with: /\A(\d+|R)\z/,
              message: I18n.t("#{ERROR_BASE_KEY}.mortlen.invalid"),
            },
            on: :after_log

  validate :validate_buyer1_economic_status, on: :before_log
  validate :validate_buyer2_economic_status, on: :before_log
  validate :validate_valid_radio_option, on: :before_log

  validate :validate_owning_org_data_given, on: :after_log
  validate :validate_owning_org_exists, on: :after_log
  validate :validate_owning_org_owns_stock, on: :after_log
  validate :validate_owning_org_permitted, on: :after_log

  validate :validate_assigned_to_exists, on: :after_log
  validate :validate_assigned_to_related, on: :after_log
  validate :validate_assigned_to_when_support, on: :after_log
  validate :validate_managing_org_related, on: :after_log
  validate :validate_relevant_collection_window, on: :after_log
  validate :validate_incomplete_soft_validations, on: :after_log

  validate :validate_uprn_exists_if_any_key_address_fields_are_blank, on: :after_log
  validate :validate_address_fields, on: :after_log
  validate :validate_if_log_already_exists, on: :after_log, if: -> { FeatureToggle.bulk_upload_duplicate_log_check_enabled? }

  validate :validate_nationality, on: :after_log
  validate :validate_buyer_2_nationality, on: :after_log
  validate :validate_mortlen_field_if_buyer_interviewed, on: :after_log

  validate :validate_nulls, on: :after_log

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

    normalise_case_insensitive_fields

    super(:before_log)
    @before_errors = errors.dup

    log.valid?

    super(:after_log)
    errors.merge!(@before_errors)

    log.errors.each do |error|
      fields = field_mapping_for_errors[error.attribute] || []

      fields.each do |field|
        next if errors.include?(field)
        next if error.type == :skip_bu_error

        question = log.form.get_question(error.attribute, log)

        if question.present? && setup_question?(question)
          errors.add(field, error.message, category: :setup)
        else
          errors.add(field, error.message)
        end
      end
    end

    add_errors_for_invalid_fields

    errors.blank?
  end

  def block_log_creation?
    block_log_creation
  end

  def inspect
    "#<BulkUpload::Sales::Year2026::RowParser:#{object_id}>"
  end

  def log_already_exists?
    return false if blank_row?

    @log_already_exists ||= SalesLog
      .where(status: %w[not_started in_progress completed])
      .exists?(duplicate_check_fields.index_with { |field| log.public_send(field) })
  end

  def purchaser_code
    field_7
  end

  def spreadsheet_duplicate_hash
    attributes.slice(
      "field_4",  # owning org
      "field_1",  # saledate
      "field_2",  # saledate
      "field_3",  # saledate
      "field_7",  # purchaser_code
      "field_21", # postcode
      "field_22", # postcode
      "field_29", # age1
      "field_30", # sexrab1
      "field_35", # ecstat1
    )
  end

  def add_duplicate_found_in_spreadsheet_errors
    spreadsheet_duplicate_hash.each_key do |field|
      errors.add(field, I18n.t("#{ERROR_BASE_KEY}.spreadsheet_dupe"), category: :setup)
    end
  end

  def add_invalid_field(field)
    invalid_fields << field
  end

private

  def normalise_case_insensitive_fields
    CASE_INSENSITIVE_FIELDS.each do |field|
      value = send(field)
      send("#{field}=", value.upcase) if value.present?
    end
  end

  def prevtenbuy2
    case field_77
    when "R"
      0
    else
      field_77
    end
  end

  def infer_buyer2_ethnic_group_from_ethnic
    case field_42
    when 1, 2, 3, 18, 20
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
      field_42
    end
  end

  def validate_uprn_exists_if_any_key_address_fields_are_blank
    if field_16.blank? && !key_address_fields_provided?
      %i[field_17 field_19 field_21 field_22].each do |field|
        errors.add(field, I18n.t("#{ERROR_BASE_KEY}.address.not_answered")) if send(field).blank?
      end
      errors.add(:field_16, I18n.t("#{ERROR_BASE_KEY}.address.not_answered", question: "UPRN."))
    end
  end

  def key_address_fields_provided?
    field_17.present? && field_19.present? && postcode_full.present?
  end

  def validate_address_fields
    if field_16.blank? || log.errors.attribute_names.include?(:uprn)
      if field_17.blank? && errors[:field_17].blank?
        errors.add(:field_17, I18n.t("#{ERROR_BASE_KEY}.not_answered", question: "address line 1."))
      end

      if field_19.blank? && errors[:field_19].blank?
        errors.add(:field_19, I18n.t("#{ERROR_BASE_KEY}.not_answered", question: "town or city."))
      end

      if field_21.blank? && errors[:field_21].blank?
        errors.add(:field_21, I18n.t("#{ERROR_BASE_KEY}.not_answered", question: "part 1 of postcode."))
      end

      if field_22.blank? && errors[:field_22].blank?
        errors.add(:field_22, I18n.t("#{ERROR_BASE_KEY}.not_answered", question: "part 2 of postcode."))
      end
    end
  end

  def shared_ownership?
    field_8 == 1
  end

  def discounted_ownership?
    field_8 == 2
  end

  def joint_purchase?
    field_12 == 1
  end

  def joint_purchase_asked?
    shared_ownership? || discounted_ownership? || field_13 == 2
  end

  def shared_or_discounted_but_not_staircasing?
    (shared_ownership? || discounted_ownership?) && field_10 != 1
  end

  def shared_ownership_initial_purchase?
    field_8 == 1 && field_10 != 1
  end

  def staircasing?
    field_8 == 1 && field_10 == 1
  end

  def two_buyers_share_address?
    field_76 == 2
  end

  def not_resale?
    field_91 == 2
  end

  def buyer_1_previous_tenure_not_1_or_2?
    field_71 != 1 && field_71 != 2
  end

  def mortgage_used?
    field_101 == 2
  end

  def social_homebuy?
    field_9 == 18
  end

  def buyers_own_all?
    field_110 == 100
  end

  def buyer_staircased_before?
    field_112 == 1
  end

  def buyer_interviewed?
    field_14 == 2
  end

  def rtb_like_sale_type?
    [9, 14, 29].include?(field_11)
  end

  def invalid_fields
    @invalid_fields ||= []
  end

  def add_errors_for_invalid_fields
    invalid_fields.each do |field|
      errors.delete(field) # take precedence over any other errors as this is a BU format issue
      errors.add(field, I18n.t("#{ERROR_BASE_KEY}.invalid_option", question: QUESTIONS[field.to_sym]))
    end
  end

  def field_mapping_for_errors
    {
      purchid: %i[field_7],
      saledate: %i[field_1 field_2 field_3],
      noint: %i[field_14],
      age1_known: %i[field_29],
      age1: %i[field_29],
      age2_known: %i[field_38],
      age2: %i[field_38],
      age3_known: %i[field_48],
      age3: %i[field_48],
      age4_known: %i[field_54],
      age4: %i[field_54],
      age5_known: %i[field_60],
      age5: %i[field_60],
      age6_known: %i[field_66],
      age6: %i[field_66],
      relat2: %i[field_37],
      relat3: %i[field_47],
      relat4: %i[field_53],
      relat5: %i[field_59],
      relat6: %i[field_65],

      ecstat1: %i[field_35],
      ecstat2: %i[field_44],
      ecstat3: %i[field_52],

      ecstat4: %i[field_58],
      ecstat5: %i[field_64],
      ecstat6: %i[field_70],
      ethnic_group: %i[field_33],
      ethnic: %i[field_33],
      nationality_all: %i[field_34],
      nationality_all_group: %i[field_34],
      income1nk: %i[field_83],
      income1: %i[field_83],
      income2nk: %i[field_85],
      income2: %i[field_85],
      inc1mort: %i[field_84],
      inc2mort: %i[field_86],
      savingsnk: %i[field_88],
      savings: %i[field_88],
      prevown: %i[field_89],
      prevten: %i[field_71],
      prevloc: %i[field_75],
      previous_la_known: %i[field_75],
      ppcodenk: %i[field_72],
      ppostcode_full: %i[field_73 field_74],
      disabled: %i[field_81],

      wheel: %i[field_82],
      beds: %i[field_26],
      proptype: %i[field_24],
      builtype: %i[field_27],
      la_known: %i[field_23],
      la: %i[field_23],

      is_la_inferred: %i[field_23],
      pcodenk: %i[field_21 field_22],
      postcode_full: %i[field_21 field_22],
      wchair: %i[field_28],

      type: %i[field_9 field_11 field_8],
      resale: %i[field_91],
      hodate: %i[field_93 field_94 field_95],

      frombeds: %i[field_96],
      fromprop: %i[field_97],
      value: value_fields,
      equity: equity_fields,
      mortgage: mortgage_fields,
      extrabor: extrabor_fields,
      deposit: deposit_fields,
      cashdis: %i[field_105],
      mrent: mrent_fields,

      has_mscharge: mscharge_fields,
      mscharge: mscharge_fields,
      grant: %i[field_129],
      discount: %i[field_130],
      owning_organisation_id: %i[field_4],
      managing_organisation_id: [:field_5],
      assigned_to: %i[field_6],
      hhregres: %i[field_78],
      hhregresstill: %i[field_79],
      armedforcesspouse: %i[field_80],

      hb: %i[field_87],
      mortlen: mortlen_fields,
      mortlen_known: mortlen_fields,
      proplen: proplen_fields,

      jointmore: %i[field_13],
      staircase: %i[field_10],
      privacynotice: %i[field_15],
      ownershipsch: %i[field_8],

      jointpur: %i[field_12],
      buy1livein: %i[field_36],
      buy2livein: %i[field_45],
      hholdcount: %i[field_46],
      stairbought: %i[field_109],
      stairowned: %i[field_110],
      socprevten: %i[field_98],
      mortgageused: mortgageused_fields,

      uprn: %i[field_16],
      address_line1: %i[field_17],
      address_line2: %i[field_18],
      town_or_city: %i[field_19],
      county: %i[field_20],
      uprn_selection: [:field_17],

      ethnic_group2: %i[field_42],
      ethnicbuy2: %i[field_42],
      nationality_all_buyer2: %i[field_43],
      nationality_all_buyer2_group: %i[field_43],

      buy2living: %i[field_76],
      prevtenbuy2: %i[field_77],

      prevshared: %i[field_90],

      staircasesale: %i[field_111],
      firststair: %i[field_112],
      numstair: %i[field_116],
      mrentprestaircasing: %i[field_123],
      lasttransaction: %i[field_117 field_118 field_119],
      initialpurchase: %i[field_113 field_114 field_115],

      sexrab1: %i[field_30],
      sexrab2: %i[field_39],
      sexrab3: %i[field_49],
      sexrab4: %i[field_55],
      sexrab5: %i[field_61],
      sexrab6: %i[field_67],

      buildheightclass: %i[field_25],

      gender_same_as_sex1: %i[field_31],
      gender_description1: %i[field_32],
      gender_same_as_sex2: %i[field_40],
      gender_description2: %i[field_41],
      gender_same_as_sex3: %i[field_50],
      gender_description3: %i[field_51],
      gender_same_as_sex4: %i[field_56],
      gender_description4: %i[field_57],
      gender_same_as_sex5: %i[field_62],
      gender_description5: %i[field_63],
      gender_same_as_sex6: %i[field_68],
      gender_description6: %i[field_69],

      hasservicechargeschanged: %i[field_125],
      newservicecharges: %i[field_126],
    }
  end

  def attributes_for_log
    attributes = {}

    attributes["purchid"] = purchaser_code
    attributes["saledate"] = saledate
    attributes["noint"] = field_14

    attributes["age1_known"] = age1_known?
    attributes["age1"] = field_29 if attributes["age1_known"]&.zero? && field_29&.match(/\A\d{1,3}\z|\AR\z/)

    attributes["age2_known"] = age2_known?
    attributes["age2"] = field_38 if attributes["age2_known"]&.zero? && field_38&.match(/\A\d{1,3}\z|\AR\z/)

    attributes["age3_known"] = age3_known?
    attributes["age3"] = field_48 if attributes["age3_known"]&.zero? && field_48&.match(/\A\d{1,3}\z|\AR\z/)

    attributes["age4_known"] = age4_known?
    attributes["age4"] = field_54 if attributes["age4_known"]&.zero? && field_54&.match(/\A\d{1,3}\z|\AR\z/)

    attributes["age5_known"] = age5_known?
    attributes["age5"] = field_60 if attributes["age5_known"]&.zero? && field_60&.match(/\A\d{1,3}\z|\AR\z/)

    attributes["age6_known"] = age6_known?
    attributes["age6"] = field_66 if attributes["age6_known"]&.zero? && field_66&.match(/\A\d{1,3}\z|\AR\z/)

    attributes["sexrab1"] = field_30
    attributes["sexrab2"] = field_39
    attributes["sexrab3"] = field_49
    attributes["sexrab4"] = field_55
    attributes["sexrab5"] = field_61
    attributes["sexrab6"] = field_67
    attributes["buildheightclass"] = field_25

    attributes["gender_same_as_sex1"] = field_31
    attributes["gender_description1"] = field_32
    attributes["gender_same_as_sex2"] = field_40
    attributes["gender_description2"] = field_41
    attributes["gender_same_as_sex3"] = field_50
    attributes["gender_description3"] = field_51
    attributes["gender_same_as_sex4"] = field_56
    attributes["gender_description4"] = field_57
    attributes["gender_same_as_sex5"] = field_62
    attributes["gender_description5"] = field_63
    attributes["gender_same_as_sex6"] = field_68
    attributes["gender_description6"] = field_69

    attributes["hasservicechargeschanged"] = field_125
    attributes["newservicecharges"] = field_126

    attributes["relat2"] = relationship_from_is_partner(field_37)
    attributes["relat3"] = relationship_from_is_partner(field_47)
    attributes["relat4"] = relationship_from_is_partner(field_53)
    attributes["relat5"] = relationship_from_is_partner(field_59)
    attributes["relat6"] = relationship_from_is_partner(field_65)

    attributes["ecstat1"] = field_35
    attributes["ecstat2"] = field_44
    attributes["ecstat3"] = field_52
    attributes["ecstat4"] = field_58
    attributes["ecstat5"] = field_64
    attributes["ecstat6"] = field_70

    attributes["details_known_2"] = details_known?(2)
    attributes["details_known_3"] = details_known?(3)
    attributes["details_known_4"] = details_known?(4)
    attributes["details_known_5"] = details_known?(5)
    attributes["details_known_6"] = details_known?(6)

    attributes["ethnic_group"] = ethnic_group_from_ethnic
    attributes["ethnic"] = field_33
    attributes["nationality_all"] = field_34 if field_34.present? && valid_nationality_options.include?(field_34.to_s)
    attributes["nationality_all_group"] = nationality_group(attributes["nationality_all"])

    attributes["income1nk"] = field_83 == "R" ? 1 : 0
    attributes["income1"] = field_83.to_i if attributes["income1nk"]&.zero? && field_83&.match(/\A\d+\z/)

    attributes["income2nk"] = field_85 == "R" ? 1 : 0
    attributes["income2"] = field_85.to_i if attributes["income2nk"]&.zero? && field_85&.match(/\A\d+\z/)

    attributes["inc1mort"] = field_84
    attributes["inc2mort"] = field_86

    attributes["savingsnk"] = field_88 == "R" ? 1 : 0
    attributes["savings"] = field_88.to_i if attributes["savingsnk"]&.zero? && field_88&.match(/\A\d+\z/)
    attributes["prevown"] = field_89

    attributes["prevten"] = field_71
    attributes["prevloc"] = field_75
    attributes["previous_la_known"] = previous_la_known
    attributes["ppcodenk"] = previous_postcode_known
    attributes["ppostcode_full"] = ppostcode_full

    attributes["disabled"] = field_81
    attributes["wheel"] = field_82
    attributes["beds"] = field_26
    attributes["proptype"] = field_24
    attributes["builtype"] = field_27
    attributes["la_known"] = field_23.present? ? 1 : 0
    attributes["la"] = field_23
    attributes["la_as_entered"] = field_23
    attributes["is_la_inferred"] = false
    attributes["pcodenk"] = 0 if postcode_full.present?
    attributes["postcode_full"] = postcode_full
    attributes["postcode_full_as_entered"] = postcode_full
    attributes["wchair"] = field_28

    attributes["type"] = sale_type
    attributes["resale"] = field_91

    attributes["hodate"] = hodate

    attributes["frombeds"] = field_96
    attributes["fromprop"] = field_97

    attributes["value"] = value
    attributes["equity"] = equity
    attributes["mortgage"] = mortgage
    attributes["extrabor"] = extrabor
    attributes["deposit"] = deposit

    attributes["cashdis"] = field_105
    attributes["mrent"] = mrent
    attributes["mscharge"] = mscharge if mscharge&.positive?
    attributes["has_mscharge"] = attributes["mscharge"].present? ? 1 : 0
    attributes["grant"] = field_129
    attributes["discount"] = field_130

    attributes["owning_organisation"] = owning_organisation
    attributes["managing_organisation"] = managing_organisation
    attributes["assigned_to"] = assigned_to || (bulk_upload.user.support? ? nil : bulk_upload.user)
    attributes["created_by"] = bulk_upload.user
    attributes["hhregres"] = field_78
    attributes["hhregresstill"] = field_79
    attributes["armedforcesspouse"] = field_80

    attributes["hb"] = field_87

    attributes["mortlen"] = mortlen != "R" ? mortlen : nil
    attributes["mortlen_known"] = mortlen_known

    attributes["proplen"] = proplen if proplen&.positive?
    attributes["proplen_asked"] = attributes["proplen"].present? ? 0 : 1
    attributes["jointmore"] = field_13
    attributes["staircase"] = field_10
    attributes["privacynotice"] = field_15
    attributes["ownershipsch"] = field_8
    attributes["jointpur"] = field_12
    attributes["buy1livein"] = field_36
    attributes["buy2livein"] = field_45
    attributes["hholdcount"] = field_46
    attributes["stairbought"] = field_109
    attributes["stairowned"] = field_110
    attributes["socprevten"] = field_98
    attributes["soctenant"] = infer_soctenant_from_prevten_and_prevtenbuy2
    attributes["mortgageused"] = mortgageused

    attributes["uprn"] = field_16
    attributes["uprn_known"] = field_16.present? ? 1 : 0
    attributes["uprn_confirmed"] = 1 if field_16.present?
    attributes["skip_update_uprn_confirmed"] = true
    attributes["address_line1"] = field_17
    attributes["address_line1_as_entered"] = field_17
    attributes["address_line2"] = field_18
    attributes["address_line2_as_entered"] = field_18
    attributes["town_or_city"] = field_19
    attributes["town_or_city_as_entered"] = field_19
    attributes["county"] = field_20
    attributes["county_as_entered"] = field_20
    attributes["address_line1_input"] = address_line1_input
    attributes["postcode_full_input"] = postcode_full
    attributes["select_best_address_match"] = true if field_16.blank?

    attributes["ethnic_group2"] = infer_buyer2_ethnic_group_from_ethnic
    attributes["ethnicbuy2"] = field_42
    attributes["nationality_all_buyer2"] = field_43 if field_43.present? && valid_nationality_options.include?(field_43.to_s)
    attributes["nationality_all_buyer2_group"] = nationality_group(attributes["nationality_all_buyer2"])

    attributes["buy2living"] = field_76
    attributes["prevtenbuy2"] = prevtenbuy2

    attributes["prevshared"] = field_90

    attributes["staircasesale"] = field_111

    attributes["firststair"] = field_112
    attributes["numstair"] = field_116
    attributes["mrentprestaircasing"] = field_123
    attributes["lasttransaction"] = lasttransaction
    attributes["initialpurchase"] = initialpurchase

    attributes["management_fee"] = field_108
    attributes["has_management_fee"] = field_108.present? && field_108.positive? ? 1 : 0

    attributes
  end

  def address_line1_input
    [field_17, field_18, field_19].compact.join(", ")
  end

  def saledate
    year = field_3.to_s.strip.length.between?(1, 2) ? field_3 + 2000 : field_3
    Date.new(year, field_2, field_1) if field_3.present? && field_2.present? && field_1.present?
  rescue Date::Error
    Date.new
  end

  def hodate
    year = field_95.to_s.strip.length.between?(1, 2) ? field_95 + 2000 : field_95
    Date.new(year, field_94, field_93) if field_95.present? && field_94.present? && field_93.present?
  rescue Date::Error
    Date.new
  end

  def lasttransaction
    year = field_119.to_s.strip.length.between?(1, 2) ? field_119 + 2000 : field_119
    Date.new(year, field_118, field_117) if field_119.present? && field_118.present? && field_117.present?
  rescue Date::Error
    Date.new
  end

  def initialpurchase
    year = field_115.to_s.strip.length.between?(1, 2) ? field_115 + 2000 : field_115
    Date.new(year, field_114, field_113) if field_115.present? && field_114.present? && field_113.present?
  rescue Date::Error
    Date.new
  end

  def age1_known?
    return 1 if field_29 == "R"

    0
  end

  [
    { person: 2, field: :field_38 },
    { person: 3, field: :field_48 },
    { person: 4, field: :field_54 },
    { person: 5, field: :field_60 },
    { person: 6, field: :field_66 },
  ].each do |hash|
    define_method("age#{hash[:person]}_known?") do
      return 1 if public_send(hash[:field]) == "R"

      0 if send("person_#{hash[:person]}_present?")
    end
  end

  def person_2_present?
    field_38.present? || field_39.present? || field_37.present? || field_40.present? || field_41.present?
  end

  def person_3_present?
    field_48.present? || field_49.present? || field_47.present? || field_50.present? || field_51.present?
  end

  def person_4_present?
    field_54.present? || field_55.present? || field_53.present? || field_56.present? || field_57.present?
  end

  def person_5_present?
    field_60.present? || field_61.present? || field_59.present? || field_62.present? || field_63.present?
  end

  def person_6_present?
    field_66.present? || field_67.present? || field_65.present? || field_68.present? || field_69.present?
  end

  def relationship_from_is_partner(is_partner)
    case is_partner
    when 1
      "P"
    when 2
      "X"
    when 3
      "R"
    end
  end

  def details_known?(person_n)
    send("person_#{person_n}_present?") ? 1 : 2
  end

  def ethnic_group_from_ethnic
    return nil if field_33.blank?

    case field_33
    when 1, 2, 3, 18, 20
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
    [field_21, field_22].compact_blank.join(" ") if field_21 || field_22
  end

  def ppostcode_full
    "#{field_73} #{field_74}" if field_73 && field_74
  end

  def sale_type
    return field_9 if shared_ownership?

    field_11 if discounted_ownership?
  end

  def value
    return field_99 if shared_ownership_initial_purchase?
    return field_128 if discounted_ownership?

    field_120 if staircasing?
  end

  def equity
    return field_100 if shared_ownership_initial_purchase?

    field_121 if staircasing?
  end

  def mortgage
    return field_102 if shared_ownership?

    field_132 if discounted_ownership?
  end

  def extrabor
    field_134 if discounted_ownership?
  end

  def deposit
    return field_104 if shared_ownership?

    field_135 if discounted_ownership?
  end

  def mrent
    return field_106 if shared_ownership_initial_purchase?

    field_124 if staircasing?
  end

  def mscharge
    return field_107 if shared_ownership?

    field_136 if discounted_ownership?
  end

  def mortlen
    return field_103 if shared_ownership?

    field_133 if discounted_ownership?
  end

  def mortlen_known
    return nil if buyer_interviewed?

    if mortlen == "R"
      1
    else
      0
    end
  end

  def proplen
    return field_92 if shared_ownership?

    field_127 if discounted_ownership?
  end

  def mortgageused
    return field_101 if shared_ownership_initial_purchase?
    return field_131 if discounted_ownership?

    field_122 if staircasing?
  end

  def value_fields
    return [:field_99] if shared_ownership_initial_purchase?
    return [:field_128] if discounted_ownership?
    return [:field_120] if staircasing?

    %i[field_99 field_128 field_120]
  end

  def equity_fields
    return [:field_100] if shared_ownership_initial_purchase?
    return [:field_121] if staircasing?

    %i[field_100 field_121]
  end

  def mortgage_fields
    return [:field_102] if shared_ownership?
    return [:field_132] if discounted_ownership?

    %i[field_102 field_132]
  end

  def extrabor_fields
    return [:field_134] if discounted_ownership?

    %i[field_134]
  end

  def deposit_fields
    return [:field_104] if shared_ownership?
    return [:field_135] if discounted_ownership?

    %i[field_104 field_135]
  end

  def mrent_fields
    return [:field_106] if shared_ownership_initial_purchase?
    return [:field_124] if staircasing?

    %i[field_106 field_124]
  end

  def mscharge_fields
    return [:field_107] if shared_ownership?
    return [:field_136] if discounted_ownership?

    %i[field_107 field_136]
  end

  def mortlen_fields
    return [:field_103] if shared_ownership?
    return [:field_133] if discounted_ownership?

    %i[field_103 field_133]
  end

  def proplen_fields
    return [:field_92] if shared_ownership?
    return [:field_127] if discounted_ownership?

    %i[field_92 field_127]
  end

  def mortgageused_fields
    return [:field_101] if shared_ownership_initial_purchase?
    return [:field_131] if discounted_ownership?
    return [:field_122] if staircasing?

    %i[field_101 field_131 field_122]
  end

  def owning_organisation
    @owning_organisation ||= Organisation.find_by_id_on_multiple_fields(field_4)
  end

  def assigned_to
    @assigned_to ||= User.where("lower(email) = ?", field_6&.downcase).first
  end

  def previous_la_known
    field_75.present? ? 1 : 0
  end

  def previous_postcode_known
    return 1 if field_72 == 2

    0 if field_72 == 1
  end

  def infer_soctenant_from_prevten_and_prevtenbuy2
    return unless shared_ownership?

    if [1, 2].include?(field_71) || [1, 2].include?(field_77.to_i)
      1
    else
      2
    end
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
      sexrab1
      ecstat1
      owning_organisation
      postcode_full
      purchid
    ]
  end

  def validate_owning_org_data_given
    if field_4.blank?
      block_log_creation!

      if errors[:field_4].blank?
        errors.add(:field_4, I18n.t("#{ERROR_BASE_KEY}.not_answered", question: "owning organisation."), category: :setup)
      end
    end
  end

  def validate_owning_org_exists
    if owning_organisation.nil?
      block_log_creation!

      if field_4.present? && errors[:field_4].blank?
        errors.add(:field_4, I18n.t("#{ERROR_BASE_KEY}.owning_organisation.not_found"), category: :setup)
      end
    end
  end

  def validate_owning_org_owns_stock
    if owning_organisation && !owning_organisation.holds_own_stock?
      block_log_creation!

      if errors[:field_4].blank?
        errors.add(:field_4, I18n.t("#{ERROR_BASE_KEY}.owning_organisation.not_stock_owner"), category: :setup)
      end
    end
  end

  def validate_owning_org_permitted
    return unless owning_organisation
    return if bulk_upload_organisation.affiliated_stock_owners.include?(owning_organisation)

    block_log_creation!

    return if errors[:field_4].present?

    if bulk_upload.user.support?
      errors.add(:field_4, I18n.t("#{ERROR_BASE_KEY}.owning_organisation.not_permitted.support", name: bulk_upload_organisation.name), category: :setup)
    else
      errors.add(:field_4, I18n.t("#{ERROR_BASE_KEY}.owning_organisation.not_permitted.not_support"), category: :setup)
    end
  end

  def validate_assigned_to_exists
    return if field_6.blank?

    unless assigned_to
      errors.add(:field_6, I18n.t("#{ERROR_BASE_KEY}.assigned_to.not_found"))
    end
  end

  def validate_assigned_to_when_support
    if field_6.blank? && bulk_upload.user.support?
      errors.add(:field_6, category: :setup, message: I18n.t("#{ERROR_BASE_KEY}.not_answered", question: "what is the CORE username of the account this sales log should be assigned to?"))
    end
  end

  def validate_assigned_to_related
    return unless assigned_to
    return if assigned_to.organisation == owning_organisation || assigned_to.organisation == managing_organisation
    return if assigned_to.organisation == owning_organisation&.absorbing_organisation || assigned_to.organisation == managing_organisation&.absorbing_organisation

    block_log_creation!
    errors.add(:field_6, I18n.t("#{ERROR_BASE_KEY}.assigned_to.organisation_not_related"), category: :setup)
  end

  def managing_organisation
    Organisation.find_by_id_on_multiple_fields(field_5)
  end

  def nationality_group(nationality_value)
    return unless nationality_value
    return 0 if nationality_value.zero?
    return 826 if nationality_value == 826

    12
  end

  def validate_managing_org_related
    if owning_organisation && managing_organisation && !owning_organisation.can_be_managed_by?(organisation: managing_organisation)
      block_log_creation!

      if errors[:field_5].blank?
        errors.add(:field_5, I18n.t("#{ERROR_BASE_KEY}.assigned_to.managing_organisation_not_related"), category: :setup)
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
          if errors.none? { |e| fields.include?(e.attribute) } && @before_errors.none? { |e| fields.include?(e.attribute) }
            errors.add(field, question.unanswered_error_message, category: :setup)
          end
        end
      else
        fields.each do |field|
          if errors.none? { |e| fields.include?(e.attribute) } && @before_errors.none? { |e| fields.include?(e.attribute) }
            errors.add(field, question.unanswered_error_message)
          end
        end
      end
    end
  end

  def validate_valid_radio_option
    log.attributes.each_key do |question_id|
      question = log.form.get_question(question_id, log)

      next if question_id == "type"

      next unless question&.type == "radio"
      next if log[question_id].blank? || question.answer_options.key?(log[question_id].to_s) || !question.page.routed_to?(log, nil)

      fields = field_mapping_for_errors[question_id.to_sym] || []

      if setup_question?(question)
        fields.each do |field|
          if errors[field].none?
            block_log_creation!
            errors.add(field, I18n.t("#{ERROR_BASE_KEY}.invalid_option", question: format_ending(QUESTIONS[field])), category: :setup)
          end
        end
      else
        fields.each do |field|
          unless errors.any? { |e| fields.include?(e.attribute) }
            errors.add(field, I18n.t("#{ERROR_BASE_KEY}.invalid_option", question: format_ending(QUESTIONS[field])))
          end
        end
      end
    end
  end

  def validate_relevant_collection_window
    return if saledate.blank? || bulk_upload.form.blank?
    return if errors.key?(:field_1) || errors.key?(:field_2) || errors.key?(:field_3)

    unless bulk_upload.form.valid_start_date_for_form?(saledate)
      errors.add(:field_1, I18n.t("#{ERROR_BASE_KEY}.saledate.outside_collection_window", year_combo: bulk_upload.year_combo, start_year: bulk_upload.year, end_year: bulk_upload.end_year), category: :setup)
      errors.add(:field_2, I18n.t("#{ERROR_BASE_KEY}.saledate.outside_collection_window", year_combo: bulk_upload.year_combo, start_year: bulk_upload.year, end_year: bulk_upload.end_year), category: :setup)
      errors.add(:field_3, I18n.t("#{ERROR_BASE_KEY}.saledate.outside_collection_window", year_combo: bulk_upload.year_combo, start_year: bulk_upload.year, end_year: bulk_upload.end_year), category: :setup)
    end
  end

  def validate_if_log_already_exists
    if log_already_exists?
      error_message = I18n.t("#{ERROR_BASE_KEY}.duplicate")

      errors.add(:field_4, error_message) # Owning org
      errors.add(:field_1, error_message) # Sale completion date
      errors.add(:field_2, error_message) # Sale completion date
      errors.add(:field_3, error_message) # Sale completion date
      errors.add(:field_21, error_message) # Postcode
      errors.add(:field_22, error_message) # Postcode
      errors.add(:field_29, error_message) # Buyer 1 age
      errors.add(:field_30, error_message) # Buyer 1 sex registered at birth
      errors.add(:field_35, error_message) # Buyer 1 working situation
      errors.add(:field_7, error_message) # Purchaser code
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
      if field_29.present? && field_29.to_i >= 16
        errors.add(:field_35, I18n.t("#{ERROR_BASE_KEY}.ecstat1.buyer_cannot_be_over_16_and_child"))
        errors.add(:field_29, I18n.t("#{ERROR_BASE_KEY}.age1.buyer_cannot_be_over_16_and_child"))
      else
        errors.add(:field_35, I18n.t("#{ERROR_BASE_KEY}.ecstat1.buyer_cannot_be_child"))
      end
    end
  end

  def validate_buyer2_economic_status
    return unless joint_purchase?

    if field_44 == 9
      if field_38.present? && field_38.to_i >= 16
        errors.add(:field_44, I18n.t("#{ERROR_BASE_KEY}.ecstat2.buyer_cannot_be_over_16_and_child"))
        errors.add(:field_38, I18n.t("#{ERROR_BASE_KEY}.age2.buyer_cannot_be_over_16_and_child"))
      else
        errors.add(:field_44, I18n.t("#{ERROR_BASE_KEY}.ecstat2.buyer_cannot_be_child"))
      end
    end
  end

  def validate_nationality
    if field_34.present? && !valid_nationality_options.include?(field_34.to_s)
      errors.add(:field_34, I18n.t("#{ERROR_BASE_KEY}.nationality.invalid"))
    end
  end

  def validate_buyer_2_nationality
    if field_43.present? && !valid_nationality_options.include?(field_43.to_s)
      errors.add(:field_43, I18n.t("#{ERROR_BASE_KEY}.nationality.invalid"))
    end
  end

  def valid_nationality_options
    %w[0] + GlobalConstants::COUNTRIES_ANSWER_OPTIONS.keys # 0 is "Prefers not to say"
  end

  def validate_mortlen_field_if_buyer_interviewed
    if buyer_interviewed? && mortlen == "R"
      errors.add(:field_103, I18n.t("#{ERROR_BASE_KEY}.mortlen.invalid_for_interviewed")) if shared_ownership?
      errors.add(:field_133, I18n.t("#{ERROR_BASE_KEY}.mortlen.invalid_for_interviewed")) if discounted_ownership?
    end
  end

  def bulk_upload_organisation
    Organisation.find(bulk_upload.organisation_id)
  end
end
