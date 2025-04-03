class BulkUpload::Lettings::Year2023::RowParser
  include ActiveModel::Model
  include ActiveModel::Attributes
  include InterruptionScreenHelper
  include FormattingHelper

  QUESTIONS = {
    field_1: "Which organisation owns this property?",
    field_2: "Which organisation manages this letting?",
    field_3: "What is the CORE username of the account this letting log should be assigned to?",
    field_4: "What is the needs type?",
    field_5: "What is the letting type?",
    field_6: "Is this letting a renewal?",
    field_7: "What is the tenancy start date?",
    field_8: "What is the tenancy start date?",
    field_9: "What is the tenancy start date?",
    field_10: "Is this a London Affordable Rent letting?",
    field_11: "Which type of Intermediate Rent is this letting?",
    field_12: "Which 'Other' type of Intermediate Rent is this letting?",
    field_13: "What is the tenant code?",
    field_14: "What is the property reference?",
    field_15: "What management group does this letting belong to?",
    field_16: "What scheme does this letting belong to?",
    field_17: "Which location is this letting for?",
    field_18: "If known, provide this property’s UPRN",
    field_19: "Address line 1",
    field_20: "Address line 2",
    field_21: "Town or city",
    field_22: "County",
    field_23: "Part 1 of the property’s postcode",
    field_24: "Part 2 of the property’s postcode",
    field_25: "What is the property’s local authority?",
    field_26: "What type was the property most recently let as?",
    field_27: "What is the reason for the property being vacant?",
    field_28: "How many times was the property offered between becoming vacant and this letting?",
    field_29: "What type of unit is the property?",
    field_30: "Which type of building is the property?",
    field_31: "Is the property built or adapted to wheelchair-user standards?",
    field_32: "How many bedrooms does the property have?",
    field_33: "What is the void date?",
    field_34: "What is the void date?",
    field_35: "What is the void date?",
    field_36: "What date were any major repairs completed on?",
    field_37: "What date were any major repairs completed on?",
    field_38: "What date were any major repairs completed on?",
    field_39: "Is this a joint tenancy?",
    field_40: "Is this a starter tenancy?",
    field_41: "What is the type of tenancy?",
    field_42: "If 'Other', what is the type of tenancy?",
    field_43: "What is the length of the fixed-term tenancy to the nearest year?",
    field_44: "Is this letting sheltered accommodation?",
    field_45: "Has tenant seen the MHCLG privacy notice?",
    field_46: "What is the lead tenant’s age?",
    field_47: "Which of these best describes the lead tenant’s gender identity?",
    field_48: "Which of these best describes the lead tenant’s ethnic background?",
    field_49: "What is the lead tenant’s nationality?",
    field_50: "Which of these best describes the lead tenant’s working situation?",
    field_51: "What is person 2’s relationship to the lead tenant?",
    field_52: "What is person 2’s age?",
    field_53: "Which of these best describes person 2’s gender identity?",
    field_54: "Which of these best describes person 2’s working situation?",
    field_55: "What is person 3’s relationship to the lead tenant?",
    field_56: "What is person 3’s age?",
    field_57: "Which of these best describes person 3’s gender identity?",
    field_58: "Which of these best describes person 3’s working situation?",
    field_59: "What is person 4’s relationship to the lead tenant?",
    field_60: "What is person 4’s age?",
    field_61: "Which of these best describes person 4’s gender identity?",
    field_62: "Which of these best describes person 4’s working situation?",
    field_63: "What is person 5’s relationship to the lead tenant?",
    field_64: "What is person 5’s age?",
    field_65: "Which of these best describes person 5’s gender identity?",
    field_66: "Which of these best describes person 5’s working situation?",
    field_67: "What is person 6’s relationship to the lead tenant?",
    field_68: "What is person 6’s age?",
    field_69: "Which of these best describes person 6’s gender identity?",
    field_70: "Which of these best describes person 6’s working situation?",
    field_71: "What is person 7’s relationship to the lead tenant?",
    field_72: "What is person 7’s age?",
    field_73: "Which of these best describes person 7’s gender identity?",
    field_74: "Which of these best describes person 7’s working situation?",
    field_75: "What is person 8’s relationship to the lead tenant?",
    field_76: "What is person 8’s age?",
    field_77: "Which of these best describes person 8’s gender identity?",
    field_78: "Which of these best describes person 8’s working situation?",
    field_79: "Does anybody in the household have links to the UK armed forces?",
    field_80: "Is this person still serving in the UK armed forces?",
    field_81: "Was this person seriously injured or ill as a result of serving in the UK armed forces?",
    field_82: "Is anybody in the household pregnant?",
    field_83: "Does anybody in the household have any disabled access needs?",
    field_84: "Does anybody in the household have any disabled access needs?",
    field_85: "Does anybody in the household have any disabled access needs?",
    field_86: "Does anybody in the household have any disabled access needs?",
    field_87: "Does anybody in the household have any disabled access needs?",
    field_88: "Does anybody in the household have any disabled access needs?",
    field_89: "Does anybody in the household have a physical or mental health condition (or other illness) expected to last 12 months or more?",
    field_90: "Does this person’s condition affect their dexterity?",
    field_91: "Does this person’s condition affect their learning or understanding or concentrating?",
    field_92: "Does this person’s condition affect their hearing?",
    field_93: "Does this person’s condition affect their memory?",
    field_94: "Does this person’s condition affect their mental health?",
    field_95: "Does this person’s condition affect their mobility?",
    field_96: "Does this person’s condition affect them socially or behaviourally?",
    field_97: "Does this person’s condition affect their stamina or breathing or fatigue?",
    field_98: "Does this person’s condition affect their vision?",
    field_99: "Does this person’s condition affect them in another way?",
    field_100: "How long has the household continuously lived in the local authority area of the new letting?",
    field_101: "How long has the household been on the local authority waiting list for the new letting?",
    field_102: "What is the tenant’s main reason for the household leaving their last settled home?",
    field_103: "If 'Other', what was the main reason for leaving their last settled home?",
    field_104: "Where was the household immediately before this letting?",
    field_105: "Did the household experience homelessness immediately before this letting?",
    field_106: "Do you know the postcode of the household’s last settled home?",
    field_107: "What is the postcode of the household’s last settled home?",
    field_108: "What is the postcode of the household’s last settled home?",
    field_109: "What is the local authority of the household’s last settled home?",
    field_110: "Was the household given 'reasonable preference' by the local authority?",
    field_111: "Reasonable preference reason They were homeless or about to lose their home (within 56 days)",
    field_112: "Reasonable preference reason They were living in insanitary, overcrowded or unsatisfactory housing",
    field_113: "Reasonable preference reason They needed to move on medical and welfare reasons (including disability)",
    field_114: "Reasonable preference reason They needed to move to avoid hardship to themselves or others",
    field_115: "Reasonable preference reason Don’t know",
    field_116: "Was the letting made under the Choice-Based Lettings (CBL)?",
    field_117: "Was the letting made under the Common Allocation Policy (CAP)?",
    field_118: "Was the letting made under the Common Housing Register (CHR)?",
    field_119: "What was the source of referral for this letting?",
    field_120: "Do you know the household’s combined total income after tax?",
    field_121: "How often does the household receive income?",
    field_122: "How much income does the household have in total?",
    field_123: "Is the tenant likely to be receiving any of these housing-related benefits?",
    field_124: "How much of the household’s income is from Universal Credit, state pensions or benefits?",
    field_125: "Does the household pay rent or other charges for the accommodation?",
    field_126: "How often does the household pay rent and other charges?",
    field_127: "If this is a care home, how much does the household pay every [time period]?",
    field_128: "What is the basic rent?",
    field_129: "What is the service charge?",
    field_130: "What is the personal service charge?",
    field_131: "What is the support charge?",
    field_132: "Total charge",
    field_133: "After the household has received any housing-related benefits, will they still need to pay for rent and charges?",
    field_134: "What do you expect the outstanding amount to be?",
  }.freeze

  ERROR_BASE_KEY = "validations.lettings.2023.bulk_upload".freeze

  attribute :bulk_upload
  attribute :block_log_creation, :boolean, default: -> { false }

  attribute :field_blank

  attribute :field_1, :string
  attribute :field_2, :string
  attribute :field_3, :string
  attribute :field_4, :integer
  attribute :field_5, :integer
  attribute :field_6, :integer
  attribute :field_7, :integer
  attribute :field_8, :integer
  attribute :field_9, :integer
  attribute :field_10, :integer
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
  attribute :field_38, :integer
  attribute :field_39, :integer
  attribute :field_40, :integer
  attribute :field_41, :integer
  attribute :field_42, :string
  attribute :field_43, :integer
  attribute :field_44, :integer
  attribute :field_45, :integer
  attribute :field_46, :string
  attribute :field_47, :string
  attribute :field_48, :integer
  attribute :field_49, :integer
  attribute :field_50, :integer
  attribute :field_51, :string
  attribute :field_52, :string
  attribute :field_53, :string
  attribute :field_54, :integer
  attribute :field_55, :string
  attribute :field_56, :string
  attribute :field_57, :string
  attribute :field_58, :integer
  attribute :field_59, :string
  attribute :field_60, :string
  attribute :field_61, :string
  attribute :field_62, :integer
  attribute :field_63, :string
  attribute :field_64, :string
  attribute :field_65, :string
  attribute :field_66, :integer
  attribute :field_67, :string
  attribute :field_68, :string
  attribute :field_69, :string
  attribute :field_70, :integer
  attribute :field_71, :string
  attribute :field_72, :string
  attribute :field_73, :string
  attribute :field_74, :integer
  attribute :field_75, :string
  attribute :field_76, :string
  attribute :field_77, :string
  attribute :field_78, :integer
  attribute :field_79, :integer
  attribute :field_80, :integer
  attribute :field_81, :integer
  attribute :field_82, :integer
  attribute :field_83, :integer
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
  attribute :field_103, :string
  attribute :field_104, :integer
  attribute :field_105, :integer
  attribute :field_106, :integer
  attribute :field_107, :string
  attribute :field_108, :string
  attribute :field_109, :string
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
  attribute :field_122, :decimal
  attribute :field_123, :integer
  attribute :field_124, :integer
  attribute :field_125, :integer
  attribute :field_126, :integer
  attribute :field_127, :decimal
  attribute :field_128, :decimal
  attribute :field_129, :decimal
  attribute :field_130, :decimal
  attribute :field_131, :decimal
  attribute :field_132, :decimal
  attribute :field_133, :integer
  attribute :field_134, :decimal

  validate :validate_valid_radio_option, on: :before_log

  validates :field_5,
            presence: {
              message: I18n.t("#{ERROR_BASE_KEY}.not_answered", question: "letting type."),
              category: :setup,
            },
            inclusion: {
              in: (1..12).to_a,
              message: I18n.t("#{ERROR_BASE_KEY}.invalid_option", question: "letting type."),
              unless: -> { field_5.blank? },
              category: :setup,
            },
            on: :after_log

  validates :field_6,
            presence: {
              message: I18n.t("#{ERROR_BASE_KEY}.not_answered", question: "property renewal."),
              category: :setup,
            },
            on: :after_log

  validates :field_7,
            presence: {
              message: I18n.t("#{ERROR_BASE_KEY}.not_answered", question: "tenancy start date (day)."),
              category: :setup,
            },
            on: :after_log

  validates :field_8,
            presence: {
              message: I18n.t("#{ERROR_BASE_KEY}.not_answered", question: "tenancy start date (month)."),
              category: :setup,
            },
            on: :after_log

  validates :field_9,
            presence: {
              message: I18n.t("#{ERROR_BASE_KEY}.not_answered", question: "tenancy start date (year)."),
              category: :setup,
            },
            format: {
              with: /\A(\d{2}|\d{4})\z/,
              message: I18n.t("#{ERROR_BASE_KEY}.startdate.year_not_two_or_four_digits"),
              category: :setup,
              unless: -> { field_9.blank? },
            },
            on: :after_log

  validates :field_16,
            presence: {
              if: proc { supported_housing? },
              message: I18n.t("#{ERROR_BASE_KEY}.not_answered", question: "scheme code."),
              category: :setup,
            },
            on: :after_log

  validates :field_116,
            presence: {
              message: I18n.t("#{ERROR_BASE_KEY}.not_answered", question: "was the letting made under the Choice-Based Lettings (CBL)?"),
              category: :not_answered,
            },
            inclusion: {
              in: [1, 2],
              message: I18n.t("#{ERROR_BASE_KEY}.invalid_option", question: "was the letting made under the Choice-Based Lettings (CBL)?"),
              if: -> { field_116.present? },
            },
            on: :after_log

  validates :field_117,
            presence: {
              message: I18n.t("#{ERROR_BASE_KEY}.not_answered", question: "was the letting made under the Common Allocation Policy (CAP)?"),
              category: :not_answered,
            },
            inclusion: {
              in: [1, 2],
              message: I18n.t("#{ERROR_BASE_KEY}.invalid_option", question: "was the letting made under the Common Allocation Policy (CAP)?"),
              if: -> { field_117.present? },
            },
            on: :after_log

  validates :field_118,
            presence: {
              message: I18n.t("#{ERROR_BASE_KEY}.not_answered", question: "was the letting made under the Common Housing Register (CHR)?"),
              category: :not_answered,
            },
            inclusion: {
              in: [1, 2],
              message: I18n.t("#{ERROR_BASE_KEY}.invalid_option", question: "was the letting made under the Common Housing Register (CHR)?"),
              if: -> { field_118.present? },
            },
            on: :after_log

  validates :field_46, format: { with: /\A\d{1,3}\z|\AR\z/, message: I18n.t("#{ERROR_BASE_KEY}.age.invalid", person_num: 1) }, on: :after_log
  validates :field_52, format: { with: /\A\d{1,3}\z|\AR\z/, message: I18n.t("#{ERROR_BASE_KEY}.age.invalid", person_num: 2) }, on: :after_log, if: proc { details_known?(2).zero? }
  validates :field_56, format: { with: /\A\d{1,3}\z|\AR\z/, message: I18n.t("#{ERROR_BASE_KEY}.age.invalid", person_num: 3) }, on: :after_log, if: proc { details_known?(3).zero? }
  validates :field_60, format: { with: /\A\d{1,3}\z|\AR\z/, message: I18n.t("#{ERROR_BASE_KEY}.age.invalid", person_num: 4) }, on: :after_log, if: proc { details_known?(4).zero? }
  validates :field_64, format: { with: /\A\d{1,3}\z|\AR\z/, message: I18n.t("#{ERROR_BASE_KEY}.age.invalid", person_num: 5) }, on: :after_log, if: proc { details_known?(5).zero? }
  validates :field_68, format: { with: /\A\d{1,3}\z|\AR\z/, message: I18n.t("#{ERROR_BASE_KEY}.age.invalid", person_num: 6) }, on: :after_log, if: proc { details_known?(6).zero? }
  validates :field_72, format: { with: /\A\d{1,3}\z|\AR\z/, message: I18n.t("#{ERROR_BASE_KEY}.age.invalid", person_num: 7) }, on: :after_log, if: proc { details_known?(7).zero? }
  validates :field_76, format: { with: /\A\d{1,3}\z|\AR\z/, message: I18n.t("#{ERROR_BASE_KEY}.age.invalid", person_num: 8) }, on: :after_log, if: proc { details_known?(8).zero? }

  validate :validate_needs_type_present, on: :after_log
  validate :validate_data_types, on: :after_log
  validate :validate_relevant_collection_window, on: :after_log
  validate :validate_la_with_local_housing_referral, on: :after_log
  validate :validate_cannot_be_la_referral_if_general_needs_and_la, on: :after_log
  validate :validate_leaving_reason_for_renewal, on: :after_log
  validate :validate_lettings_type_matches_bulk_upload, on: :after_log
  validate :validate_only_one_housing_needs_type, on: :after_log
  validate :validate_no_disabled_needs_conjunction, on: :after_log
  validate :validate_dont_know_disabled_needs_conjunction, on: :after_log
  validate :validate_no_and_dont_know_disabled_needs_conjunction, on: :after_log
  validate :validate_no_housing_needs_questions_answered, on: :after_log
  validate :validate_reasonable_preference_homeless, on: :after_log
  validate :validate_condition_effects, on: :after_log
  validate :validate_if_log_already_exists, on: :after_log, if: -> { FeatureToggle.bulk_upload_duplicate_log_check_enabled? }

  validate :validate_owning_org_data_given, on: :after_log
  validate :validate_owning_org_exists, on: :after_log
  validate :validate_owning_org_owns_stock, on: :after_log
  validate :validate_owning_org_permitted, on: :after_log

  validate :validate_managing_org_data_given, on: :after_log
  validate :validate_managing_org_exists, on: :after_log
  validate :validate_managing_org_related, on: :after_log

  validate :validate_related_scheme_exists, on: :after_log
  validate :validate_scheme_data_given, on: :after_log

  validate :validate_related_location_exists, on: :after_log
  validate :validate_location_data_given, on: :after_log

  validate :validate_assigned_to_exists, on: :after_log
  validate :validate_assigned_to_related, on: :after_log

  validate :validate_declaration_acceptance, on: :after_log

  validate :validate_nulls, on: :after_log

  validate :validate_uprn_exists_if_any_key_address_fields_are_blank, on: :after_log, unless: -> { supported_housing? }

  validate :validate_incomplete_soft_validations, on: :after_log

  validate :validate_correct_intermediate_rent_type, on: :after_log, if: proc { renttype == :intermediate }
  validate :validate_correct_affordable_rent_type, on: :after_log, if: proc { renttype == :affordable }

  def self.question_for_field(field)
    QUESTIONS[field]
  end

  def valid?
    return @valid if @valid

    errors.clear

    return @valid = true if blank_row?

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

    @valid = errors.blank?
  end

  def blank_row?
    attribute_set
      .to_hash
      .reject { |k, _| %w[bulk_upload block_log_creation field_blank].include?(k) }
      .values
      .reject(&:blank?)
      .compact
      .empty?
  end

  def log
    @log ||= LettingsLog.new(attributes_for_log)
  end

  def block_log_creation!
    self.block_log_creation = true
  end

  def block_log_creation?
    block_log_creation
  end

  def tenant_code
    field_13
  end

  def property_ref
    field_14
  end

  def log_already_exists?
    @log_already_exists ||= LettingsLog
      .where(status: %w[not_started in_progress completed])
      .exists?(duplicate_check_fields.index_with { |field| log.public_send(field) })
  end

  def spreadsheet_duplicate_hash
    attributes.slice(
      "field_1",   # owning org
      "field_7",   # startdate
      "field_8",   # startdate
      "field_9",   # startdate
      "field_13",  # tenancycode
      !general_needs? ? location_field.to_s : nil, # location
      !supported_housing? ? "field_23" : nil,  # postcode
      !supported_housing? ? "field_24" : nil,  # postcode
      "field_46",  # age1
      "field_47",  # sex1
      "field_50",  # ecstat1
      "field_132", # tcharge
    )
  end

  def add_duplicate_found_in_spreadsheet_errors
    spreadsheet_duplicate_hash.each_key do |field|
      errors.add(field, I18n.t("#{ERROR_BASE_KEY}.spreadsheet_dupe"), category: :setup)
    end
  end

private

  def validate_declaration_acceptance
    unless field_45 == 1
      errors.add(:field_45, I18n.t("#{ERROR_BASE_KEY}.declaration.missing"), category: :setup)
    end
  end

  def validate_valid_radio_option
    log.attributes.each do |question_id, _v|
      question = log.form.get_question(question_id, log)

      next unless question&.type == "radio"
      next if log[question_id].blank? || question.answer_options.key?(log[question_id].to_s) || !question.page.routed_to?(log, nil)

      fields = field_mapping_for_errors[question_id.to_sym] || []

      fields.each do |field|
        if setup_question?(question)
          errors.add(field, I18n.t("#{ERROR_BASE_KEY}.invalid_option", question: format_ending(QUESTIONS[field])), category: :setup)
        else
          errors.add(field, I18n.t("#{ERROR_BASE_KEY}.invalid_option", question: format_ending(QUESTIONS[field])))
        end
      end
    end
  end

  def validate_assigned_to_exists
    return if field_3.blank?

    unless assigned_to
      errors.add(:field_3, I18n.t("#{ERROR_BASE_KEY}.assigned_to.not_found"))
    end
  end

  def validate_assigned_to_related
    return unless assigned_to
    return if assigned_to.organisation == owning_organisation || assigned_to.organisation == managing_organisation
    return if assigned_to.organisation == owning_organisation&.absorbing_organisation || assigned_to.organisation == managing_organisation&.absorbing_organisation

    block_log_creation!
    errors.add(:field_3, I18n.t("#{ERROR_BASE_KEY}.assigned_to.organisation_not_related"))
  end

  def assigned_to
    @assigned_to ||= User.where("lower(email) = ?", field_3&.downcase).first
  end

  def validate_uprn_exists_if_any_key_address_fields_are_blank
    if field_18.blank? && (field_19.blank? || field_21.blank?)
      errors.add(:field_18, I18n.t("#{ERROR_BASE_KEY}.not_answered", question: "UPRN."), category: :not_answered)
    end
  end

  def validate_incomplete_soft_validations
    routed_to_soft_validation_questions = log.form.questions.filter { |q| q.type == "interruption_screen" && q.page.routed_to?(log, nil) }.compact
    routed_to_soft_validation_questions.each do |question|
      next if question.completed?(log)

      question.page.interruption_screen_question_ids.each do |interruption_screen_question_id|
        next if log.form.questions.none? { |q| q.id == interruption_screen_question_id && q.page.routed_to?(log, nil) }

        field_mapping_for_errors[interruption_screen_question_id.to_sym]&.each do |field|
          if errors.none? { |e| field_mapping_for_errors[interruption_screen_question_id.to_sym].include?(e.attribute) }
            error_message = [display_title_text(question.page.title_text, log), display_informative_text(question.page.informative_text, log)].reject(&:empty?).join(" ")
            errors.add(field, message: error_message, category: :soft_validation)
          end
        end
      end
    end
  end

  def duplicate_check_fields
    [
      "startdate",
      "age1",
      "sex1",
      "ecstat1",
      "owning_organisation",
      "tcharge",
      !supported_housing? ? "postcode_full" : nil,
      !general_needs? ? "location" : nil,
      "tenancycode",
      log.chcharge.present? ? "chcharge" : nil,
    ].compact
  end

  def validate_needs_type_present
    if field_4.blank?
      errors.add(:field_4, I18n.t("#{ERROR_BASE_KEY}.not_answered", question: "needs type."), category: :setup)
    end
  end

  def validate_no_and_dont_know_disabled_needs_conjunction
    if field_87 == 1 && field_88 == 1
      errors.add(:field_87, I18n.t("#{ERROR_BASE_KEY}.housingneeds.no_and_dont_know_disabled_needs_conjunction"))
      errors.add(:field_88, I18n.t("#{ERROR_BASE_KEY}.housingneeds.no_and_dont_know_disabled_needs_conjunction"))
    end
  end

  def validate_dont_know_disabled_needs_conjunction
    if field_88 == 1 && [field_83, field_84, field_85, field_86].count(1).positive?
      %i[field_88 field_83 field_84 field_85 field_86].each do |field|
        errors.add(field, I18n.t("#{ERROR_BASE_KEY}.housingneeds.dont_know_disabled_needs_conjunction")) if send(field) == 1
      end
    end
  end

  def validate_no_disabled_needs_conjunction
    if field_87 == 1 && [field_83, field_84, field_85, field_86].count(1).positive?
      %i[field_87 field_83 field_84 field_85 field_86].each do |field|
        errors.add(field, I18n.t("#{ERROR_BASE_KEY}.housingneeds.no_disabled_needs_conjunction")) if send(field) == 1
      end
    end
  end

  def validate_only_one_housing_needs_type
    if [field_83, field_84, field_85].count(1) > 1
      %i[field_83 field_84 field_85].each do |field|
        errors.add(field, I18n.t("#{ERROR_BASE_KEY}.housingneeds_type.only_one_option_permitted")) if send(field) == 1
      end
    end
  end

  def validate_no_housing_needs_questions_answered
    if [field_83, field_84, field_85, field_86, field_87, field_88].all?(&:blank?)
      errors.add(:field_87, I18n.t("#{ERROR_BASE_KEY}.not_answered", question: "anybody with disabled access needs."), category: :not_answered)
      errors.add(:field_86, I18n.t("#{ERROR_BASE_KEY}.not_answered", question: "other access needs."), category: :not_answered)
      %i[field_83 field_84 field_85].each do |field|
        errors.add(field, I18n.t("#{ERROR_BASE_KEY}.not_answered", question: "disabled access needs type."), category: :not_answered)
      end
    end
  end

  def validate_reasonable_preference_homeless
    reason_fields = %i[field_111 field_112 field_113 field_114 field_115]
    if field_110 == 1 && reason_fields.all? { |field| attributes[field.to_s].blank? }
      reason_fields.each do |field|
        errors.add(field, I18n.t("#{ERROR_BASE_KEY}.not_answered", question: "reason for reasonable preference."), category: :not_answered)
      end
    end
  end

  def validate_condition_effects
    illness_option_fields = %i[field_98 field_92 field_95 field_90 field_91 field_93 field_94 field_97 field_96 field_99]
    if household_no_illness?
      illness_option_fields.each do |field|
        if attributes[field.to_s] == 1
          errors.add(field, I18n.t("#{ERROR_BASE_KEY}.condition_effects.no_choices"))
        end
      end
    elsif illness_option_fields.all? { |field| attributes[field.to_s].blank? }
      illness_option_fields.each do |field|
        errors.add(field, I18n.t("#{ERROR_BASE_KEY}.not_answered", question: "how is person affected by condition or illness."), category: :not_answered)
      end
    end
  end

  def household_no_illness?
    field_89 != 1
  end

  def validate_lettings_type_matches_bulk_upload
    if [1, 3, 5, 7, 9, 11].include?(field_5) && !general_needs?
      block_log_creation!
      errors.add(:field_4, I18n.t("#{ERROR_BASE_KEY}.needstype.lettype_not_supported_housing"), category: :setup)
      errors.add(:field_5, I18n.t("#{ERROR_BASE_KEY}.lettype.needstype_supported_housing"), category: :setup)
    end

    if [2, 4, 6, 8, 10, 12].include?(field_5) && !supported_housing?
      block_log_creation!
      errors.add(:field_4, I18n.t("#{ERROR_BASE_KEY}.needstype.lettype_not_general_needs"), category: :setup)
      errors.add(:field_5, I18n.t("#{ERROR_BASE_KEY}.lettype.needstype_general_needs"), category: :setup)
    end
  end

  def validate_leaving_reason_for_renewal
    if field_6 == 1 && ![40, 42].include?(field_102)
      errors.add(:field_102, I18n.t("#{ERROR_BASE_KEY}.reason.renewal_reason_needed"))
    end
  end

  def general_needs?
    field_4 == 1
  end

  def supported_housing?
    field_4 == 2
  end

  def validate_cannot_be_la_referral_if_general_needs_and_la
    if field_119 == 4 && general_needs? && owning_organisation && owning_organisation.la?
      errors.add :field_119, I18n.t("#{ERROR_BASE_KEY}.referral.general_needs_prp_referred_by_la")
    end
  end

  def validate_la_with_local_housing_referral
    if field_119 == 3 && owning_organisation && owning_organisation.la?
      errors.add(:field_119, I18n.t("#{ERROR_BASE_KEY}.referral.nominated_by_local_ha_but_la"))
    end
  end

  def validate_relevant_collection_window
    return if startdate.blank? || bulk_upload.form.blank?

    unless bulk_upload.form.valid_start_date_for_form?(startdate)
      errors.add(:field_7, I18n.t("#{ERROR_BASE_KEY}.startdate.outside_collection_window", year_combo: bulk_upload.year_combo, start_year: bulk_upload.year, end_year: bulk_upload.end_year), category: :setup)
      errors.add(:field_8, I18n.t("#{ERROR_BASE_KEY}.startdate.outside_collection_window", year_combo: bulk_upload.year_combo, start_year: bulk_upload.year, end_year: bulk_upload.end_year), category: :setup)
      errors.add(:field_9, I18n.t("#{ERROR_BASE_KEY}.startdate.outside_collection_window", year_combo: bulk_upload.year_combo, start_year: bulk_upload.year, end_year: bulk_upload.end_year), category: :setup)
    end
  end

  def validate_data_types
    unless attribute_set["field_5"].value_before_type_cast&.match?(/^\d+\.?0*$/)
      errors.add(:field_5, I18n.t("#{ERROR_BASE_KEY}.invalid_number", question: "letting type."))
    end
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
          if errors.select { |e| fields.include?(e.attribute) }.none?
            question_text = question.error_display_label.presence || "this question."
            errors.add(field, I18n.t("#{ERROR_BASE_KEY}.not_answered", question: format_ending(question_text)), category: :setup) if field.present?
          end
        end
      else
        fields.each do |field|
          unless errors.any? { |e| fields.include?(e.attribute) }
            question_text = question.error_display_label.presence || "this question."
            errors.add(field, I18n.t("#{ERROR_BASE_KEY}.not_answered", question: format_ending(question_text)), category: :not_answered)
          end
        end
      end
    end
  end

  def validate_related_location_exists
    if scheme && location_id.present? && location.nil? && location_field.present?
      block_log_creation!
      errors.add(location_field, I18n.t("#{ERROR_BASE_KEY}.scheme.must_relate_to_org", capitalised_location_or_scheme: location_or_scheme.capitalize, location_or_scheme:), category: :setup)
    end
  end

  def validate_location_data_given
    if supported_housing? && location_id.blank? && location_field.present?
      block_log_creation!
      errors.add(location_field, I18n.t("#{ERROR_BASE_KEY}.not_answered", question: "#{location_or_scheme} code."), category: :setup)
    end
  end

  def validate_related_scheme_exists
    if scheme_id.present? && scheme_field.present? && owning_organisation.present? && managing_organisation.present? && scheme.nil?
      block_log_creation!
      errors.add(scheme_field, I18n.t("#{ERROR_BASE_KEY}.scheme.does_not_belong_to_org", scheme_or_management_group:), category: :setup)
    end
  end

  def validate_scheme_data_given
    if supported_housing? && scheme_field.present? && scheme_id.blank?
      block_log_creation!
      errors.add(scheme_field, I18n.t("#{ERROR_BASE_KEY}.not_answered", question: "#{scheme_or_management_group} code."), category: :setup)
    end
  end

  def validate_managing_org_related
    if owning_organisation && managing_organisation && !owning_organisation.can_be_managed_by?(organisation: managing_organisation)
      block_log_creation!

      if errors[:field_2].blank?
        errors.add(:field_2, I18n.t("#{ERROR_BASE_KEY}.managing_organisation.no_relationship"), category: :setup)
      end
    end
  end

  def validate_managing_org_exists
    if managing_organisation.nil?
      block_log_creation!

      if errors[:field_2].blank?
        errors.add(:field_2, I18n.t("#{ERROR_BASE_KEY}.managing_organisation.not_found"), category: :setup)
      end
    end
  end

  def validate_managing_org_data_given
    if field_2.blank?
      block_log_creation!
      errors.add(:field_2, I18n.t("#{ERROR_BASE_KEY}.managing_organisation.not_answered"), category: :setup)
    end
  end

  def validate_owning_org_owns_stock
    if owning_organisation && !owning_organisation.holds_own_stock?
      block_log_creation!

      if errors[:field_1].blank?
        errors.add(:field_1, I18n.t("#{ERROR_BASE_KEY}.owning_organisation.not_stock_owner"), category: :setup)
      end
    end
  end

  def validate_owning_org_exists
    if owning_organisation.nil?
      block_log_creation!

      if errors[:field_1].blank?
        errors.add(:field_1, I18n.t("#{ERROR_BASE_KEY}.owning_organisation.not_found"), category: :setup)
      end
    end
  end

  def validate_owning_org_data_given
    if field_1.blank?
      block_log_creation!
      errors.add(:field_1, I18n.t("#{ERROR_BASE_KEY}.not_answered", question: "owning organisation."), category: :setup)
    end
  end

  def validate_owning_org_permitted
    if owning_organisation && !bulk_upload.user.organisation.affiliated_stock_owners.include?(owning_organisation)
      block_log_creation!

      if errors[:field_1].blank?
        errors.add(:field_1, I18n.t("#{ERROR_BASE_KEY}.owning_organisation.not_permitted"), category: :setup)
      end
    end
  end

  def validate_correct_intermediate_rent_type
    if field_11.blank? || ![1, 2, 3].include?(field_11.to_i)
      errors.add(:field_11, I18n.t("#{ERROR_BASE_KEY}.not_answered", question: "intermediate rent type."), category: :setup)
    end
  end

  def validate_correct_affordable_rent_type
    if field_10.blank? || ![1, 2, 3].include?(field_10.to_i)
      errors.add(:field_10, I18n.t("#{ERROR_BASE_KEY}.not_answered", question: "is this a London Affordable Rent letting."), category: :setup)
    end
  end

  def setup_question?(question)
    log.form.setup_sections[0].subsections[0].questions.include?(question)
  end

  def validate_if_log_already_exists
    if log_already_exists?
      error_message = I18n.t("#{ERROR_BASE_KEY}.duplicate")

      errors.add(:field_1, error_message) # owning_organisation
      errors.add(:field_7, error_message) # startdate
      errors.add(:field_8, error_message) # startdate
      errors.add(:field_9, error_message) # startdate
      errors.add(:field_13, error_message) # tenancycode
      errors.add(location_field, error_message) if !general_needs? && location_field.present? # location
      errors.add(:field_16, error_message) if !general_needs? && location_field.blank? # add to Scheme field as unclear whether log uses New or Old CORE ids
      errors.add(:field_23, error_message) unless supported_housing? # postcode_full
      errors.add(:field_24, error_message) unless supported_housing? # postcode_full
      errors.add(:field_25, error_message) unless supported_housing? # la
      errors.add(:field_46, error_message) # age1
      errors.add(:field_47, error_message) # sex1
      errors.add(:field_50, error_message) # ecstat1
      errors.add(:field_132, error_message) # tcharge
      errors.add(:field_127, error_message) if log.chcharge.present? # chcharge
      errors.add(:field_125, error_message) unless general_needs? # household_charge
    end
  end

  def field_mapping_for_errors
    {
      lettype: [:field_5],
      tenancycode: [:field_13],
      postcode_known: %i[field_25 field_23 field_24],
      postcode_full: %i[field_25 field_23 field_24],
      la: %i[field_25],
      owning_organisation: [:field_1],
      managing_organisation: [:field_2],
      owning_organisation_id: [:field_1],
      managing_organisation_id: [:field_2],
      renewal: [:field_6],
      scheme_id: (scheme_field.present? ? [scheme_field] : nil),
      scheme: (scheme_field.present? ? [scheme_field] : nil),
      location_id: (location_field.present? ? [location_field] : nil),
      location: (location_field.present? ? [location_field] : nil),
      assigned_to: [:field_3],
      needstype: [:field_4],
      rent_type: %i[field_5 field_10 field_11],
      startdate: %i[field_7 field_8 field_9],
      unittype_gn: %i[field_29],
      builtype: %i[field_30],
      wchair: %i[field_31],
      beds: %i[field_32],
      joint: %i[field_39],
      startertenancy: %i[field_40],
      tenancy: %i[field_41],
      tenancyother: %i[field_42],
      tenancylength: %i[field_43],
      declaration: %i[field_45],

      age1_known: %i[field_46],
      age1: %i[field_46],
      age2_known: %i[field_52],
      age2: %i[field_52],
      age3_known: %i[field_56],
      age3: %i[field_56],
      age4_known: %i[field_60],
      age4: %i[field_60],
      age5_known: %i[field_64],
      age5: %i[field_64],
      age6_known: %i[field_68],
      age6: %i[field_68],
      age7_known: %i[field_72],
      age7: %i[field_72],
      age8_known: %i[field_76],
      age8: %i[field_76],

      sex1: %i[field_47],
      sex2: %i[field_53],
      sex3: %i[field_57],
      sex4: %i[field_61],
      sex5: %i[field_65],
      sex6: %i[field_69],
      sex7: %i[field_73],
      sex8: %i[field_77],

      ethnic_group: %i[field_48],
      ethnic: %i[field_48],
      national: %i[field_49],

      relat2: %i[field_51],
      relat3: %i[field_55],
      relat4: %i[field_59],
      relat5: %i[field_63],
      relat6: %i[field_67],
      relat7: %i[field_71],
      relat8: %i[field_75],

      ecstat1: %i[field_50],
      ecstat2: %i[field_54],
      ecstat3: %i[field_58],
      ecstat4: %i[field_62],
      ecstat5: %i[field_66],
      ecstat6: %i[field_70],
      ecstat7: %i[field_74],
      ecstat8: %i[field_78],

      armedforces: %i[field_79],
      leftreg: %i[field_80],
      reservist: %i[field_81],
      preg_occ: %i[field_82],
      housingneeds: %i[field_82],

      illness: %i[field_89],

      layear: %i[field_100],
      waityear: %i[field_101],
      reason: %i[field_102],
      reasonother: %i[field_103],
      prevten: %i[field_104],
      homeless: %i[field_105],

      prevloc: %i[field_109],
      previous_la_known: %i[field_109],
      ppcodenk: %i[field_106],
      ppostcode_full: %i[field_107 field_108],

      reasonpref: %i[field_110],
      rp_homeless: %i[field_111],
      rp_insan_unsat: %i[field_112],
      rp_medwel: %i[field_113],
      rp_hardship: %i[field_114],
      rp_dontknow: %i[field_115],

      cbl: %i[field_116],
      chr: %i[field_118],
      cap: %i[field_117],
      letting_allocation: %i[field_116 field_117 field_118],

      referral: %i[field_119],

      net_income_known: %i[field_120],
      earnings: %i[field_122],
      incfreq: %i[field_121],
      hb: %i[field_123],
      benefits: %i[field_124],

      period: %i[field_126],
      brent: %i[field_128],
      scharge: %i[field_129],
      pscharge: %i[field_130],
      supcharg: %i[field_131],
      tcharge: %i[field_132],
      chcharge: %i[field_127],
      household_charge: %i[field_125],
      hbrentshortfall: %i[field_133],
      tshortfall: %i[field_134],

      unitletas: %i[field_26],
      rsnvac: %i[field_27],
      sheltered: %i[field_44],

      illness_type_1: %i[field_98],
      illness_type_2: %i[field_92],
      illness_type_3: %i[field_95],
      illness_type_4: %i[field_90],
      illness_type_5: %i[field_91],
      illness_type_6: %i[field_93],
      illness_type_7: %i[field_94],
      illness_type_8: %i[field_97],
      illness_type_9: %i[field_96],
      illness_type_10: %i[field_99],

      irproduct_other: %i[field_12],

      offered: %i[field_28],
      propcode: %i[field_14],

      majorrepairs: %i[field_36 field_37 field_38],
      mrcdate: %i[field_36 field_37 field_38],

      voiddate: %i[field_33 field_34 field_35],

      uprn: [:field_18],
      address_line1: [:field_19],
      address_line2: [:field_20],
      town_or_city: [:field_21],
      county: [:field_22],
    }.compact
  end

  def attribute_set
    @attribute_set ||= instance_variable_get(:@attributes)
  end

  def questions
    @questions ||= log.form.subsections.flat_map { |ss| ss.applicable_questions(log) }
  end

  def attributes_for_log
    attributes = {}

    attributes["lettype"] = field_5
    attributes["tenancycode"] = field_13
    attributes["la"] = field_25
    attributes["postcode_known"] = postcode_known
    attributes["postcode_full"] = postcode_full
    attributes["owning_organisation"] = owning_organisation
    attributes["managing_organisation"] = managing_organisation
    attributes["renewal"] = renewal
    attributes["scheme"] = scheme
    attributes["location"] = location
    attributes["assigned_to"] = assigned_to || bulk_upload.user
    attributes["created_by"] = bulk_upload.user
    attributes["needstype"] = field_4
    attributes["rent_type"] = rent_type
    attributes["startdate"] = startdate
    attributes["unittype_gn"] = field_29
    attributes["builtype"] = field_30
    attributes["wchair"] = field_31
    attributes["beds"] = field_32
    attributes["joint"] = field_39
    attributes["startertenancy"] = field_40
    attributes["tenancy"] = field_41
    attributes["tenancyother"] = field_42
    attributes["tenancylength"] = field_43
    attributes["declaration"] = field_45

    attributes["age1_known"] = age1_known?
    attributes["age1"] = field_46 if attributes["age1_known"]&.zero? && field_46&.match(/\A\d{1,3}\z|\AR\z/)

    attributes["age2_known"] = age2_known?
    attributes["age2"] = field_52 if attributes["age2_known"]&.zero? && field_52&.match(/\A\d{1,3}\z|\AR\z/)

    attributes["age3_known"] = age3_known?
    attributes["age3"] = field_56 if attributes["age3_known"]&.zero? && field_56&.match(/\A\d{1,3}\z|\AR\z/)

    attributes["age4_known"] = age4_known?
    attributes["age4"] = field_60 if attributes["age4_known"]&.zero? && field_60&.match(/\A\d{1,3}\z|\AR\z/)

    attributes["age5_known"] = age5_known?
    attributes["age5"] = field_64 if attributes["age5_known"]&.zero? && field_64&.match(/\A\d{1,3}\z|\AR\z/)

    attributes["age6_known"] = age6_known?
    attributes["age6"] = field_68 if attributes["age6_known"]&.zero? && field_68&.match(/\A\d{1,3}\z|\AR\z/)

    attributes["age7_known"] = age7_known?
    attributes["age7"] = field_72 if attributes["age7_known"]&.zero? && field_72&.match(/\A\d{1,3}\z|\AR\z/)

    attributes["age8_known"] = age8_known?
    attributes["age8"] = field_76 if attributes["age8_known"]&.zero? && field_76&.match(/\A\d{1,3}\z|\AR\z/)

    attributes["sex1"] = field_47
    attributes["sex2"] = field_53
    attributes["sex3"] = field_57
    attributes["sex4"] = field_61
    attributes["sex5"] = field_65
    attributes["sex6"] = field_69
    attributes["sex7"] = field_73
    attributes["sex8"] = field_77

    attributes["ethnic_group"] = ethnic_group_from_ethnic
    attributes["ethnic"] = field_48
    attributes["national"] = field_49

    attributes["relat2"] = field_51
    attributes["relat3"] = field_55
    attributes["relat4"] = field_59
    attributes["relat5"] = field_63
    attributes["relat6"] = field_67
    attributes["relat7"] = field_71
    attributes["relat8"] = field_75

    attributes["ecstat1"] = field_50
    attributes["ecstat2"] = field_54
    attributes["ecstat3"] = field_58
    attributes["ecstat4"] = field_62
    attributes["ecstat5"] = field_66
    attributes["ecstat6"] = field_70
    attributes["ecstat7"] = field_74
    attributes["ecstat8"] = field_78

    attributes["details_known_2"] = details_known?(2)
    attributes["details_known_3"] = details_known?(3)
    attributes["details_known_4"] = details_known?(4)
    attributes["details_known_5"] = details_known?(5)
    attributes["details_known_6"] = details_known?(6)
    attributes["details_known_7"] = details_known?(7)
    attributes["details_known_8"] = details_known?(8)

    attributes["armedforces"] = field_79
    attributes["leftreg"] = leftreg
    attributes["reservist"] = field_81

    attributes["preg_occ"] = field_82

    attributes["housingneeds"] = housingneeds
    attributes["housingneeds_type"] = housingneeds_type
    attributes["housingneeds_other"] = housingneeds_other

    attributes["illness"] = field_89

    attributes["layear"] = field_100
    attributes["waityear"] = field_101
    attributes["reason"] = field_102
    attributes["reasonother"] = field_103
    attributes["prevten"] = field_104
    attributes["homeless"] = field_105

    attributes["prevloc"] = prevloc
    attributes["previous_la_known"] = previous_la_known
    attributes["ppcodenk"] = ppcodenk
    attributes["ppostcode_full"] = ppostcode_full

    attributes["reasonpref"] = field_110
    attributes["rp_homeless"] = field_111
    attributes["rp_insan_unsat"] = field_112
    attributes["rp_medwel"] = field_113
    attributes["rp_hardship"] = field_114
    attributes["rp_dontknow"] = field_115

    attributes["cbl"] = cbl
    attributes["chr"] = chr
    attributes["cap"] = cap
    attributes["letting_allocation_unknown"] = letting_allocation_unknown

    attributes["referral"] = field_119

    attributes["net_income_known"] = net_income_known
    attributes["earnings"] = earnings
    attributes["incfreq"] = field_121
    attributes["hb"] = field_123
    attributes["benefits"] = field_124

    attributes["period"] = field_126
    attributes["brent"] = field_128
    attributes["scharge"] = field_129
    attributes["pscharge"] = field_130
    attributes["supcharg"] = field_131
    attributes["tcharge"] = field_132
    attributes["chcharge"] = field_127
    attributes["is_carehome"] = is_carehome
    attributes["household_charge"] = supported_housing? ? field_125 : nil
    attributes["hbrentshortfall"] = field_133
    attributes["tshortfall_known"] = tshortfall_known
    attributes["tshortfall"] = field_134

    attributes["hhmemb"] = hhmemb

    attributes["unitletas"] = field_26
    attributes["rsnvac"] = rsnvac
    attributes["sheltered"] = field_44

    attributes["illness_type_1"] = field_98
    attributes["illness_type_2"] = field_92
    attributes["illness_type_3"] = field_95
    attributes["illness_type_4"] = field_90
    attributes["illness_type_5"] = field_91
    attributes["illness_type_6"] = field_93
    attributes["illness_type_7"] = field_94
    attributes["illness_type_8"] = field_97
    attributes["illness_type_9"] = field_96
    attributes["illness_type_10"] = field_99

    attributes["irproduct_other"] = field_12

    attributes["offered"] = field_28

    attributes["propcode"] = field_14

    attributes["majorrepairs"] = majorrepairs

    attributes["mrcdate"] = mrcdate

    attributes["voiddate"] = voiddate

    attributes["first_time_property_let_as_social_housing"] = first_time_property_let_as_social_housing

    attributes["uprn_known"] = field_18.present? ? 1 : 0
    attributes["uprn_confirmed"] = 1 if field_18.present?
    attributes["skip_update_uprn_confirmed"] = true
    attributes["uprn"] = field_18
    attributes["address_line1"] = field_19
    attributes["address_line2"] = field_20
    attributes["town_or_city"] = field_21
    attributes["county"] = field_22

    attributes
  end

  def postcode_known
    if postcode_full.present?
      1
    elsif field_25.present?
      0
    end
  end

  def postcode_full
    "#{field_23} #{field_24}" if field_23 && field_24
  end

  def owning_organisation
    Organisation.find_by_id_on_multiple_fields(field_1)
  end

  def managing_organisation
    Organisation.find_by_id_on_multiple_fields(field_2)
  end

  def renewal
    case field_6
    when 1
      1
    when 2
      0
    else
      field_6
    end
  end

  def rsnvac
    field_27
  end

  def scheme
    return if scheme_id.nil? || owning_organisation.nil? || managing_organisation.nil?

    @scheme ||= Scheme.where(id: (owning_organisation.owned_schemes + managing_organisation.owned_schemes).map(&:id)).find_by_id_on_multiple_fields(scheme_id, location_id)
  end

  def location
    return if scheme.nil?

    @location ||= scheme.locations.find_by_id_on_multiple_fields(location_id)
  end

  def log_uses_new_scheme_id?
    field_16&.strip&.start_with?("S")
  end

  def log_uses_old_scheme_id?
    field_16.present? && !field_16.strip.start_with?("S")
  end

  def scheme_field
    return :field_16 if log_uses_new_scheme_id?
    return :field_15 if log_uses_old_scheme_id?
  end

  def scheme_id
    return field_16.strip if log_uses_new_scheme_id?
    return field_15 if log_uses_old_scheme_id?
  end

  def location_field
    return :field_17 if log_uses_new_scheme_id?
    return :field_16 if log_uses_old_scheme_id?
  end

  def location_id
    return field_17 if log_uses_new_scheme_id?
    return field_16 if log_uses_old_scheme_id?
  end

  def scheme_or_management_group
    log_uses_new_scheme_id? ? "scheme" : "management group"
  end

  def location_or_scheme
    log_uses_new_scheme_id? ? "location" : "scheme"
  end

  def renttype
    case field_5
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
      LettingsLog::RENT_TYPE[:social_rent]
    when :affordable
      case field_10
      when 1
        LettingsLog::RENT_TYPE[:london_affordable_rent]
      when 2, 3
        LettingsLog::RENT_TYPE[:affordable_rent]
      end
    when :intermediate
      case field_11
      when 1
        LettingsLog::RENT_TYPE[:rent_to_buy]
      when 2
        LettingsLog::RENT_TYPE[:london_living_rent]
      when 3
        LettingsLog::RENT_TYPE[:other_intermediate_rent_product]
      end
    end
  end

  def startdate
    year = field_9.to_s.strip.length.between?(1, 2) ? field_9 + 2000 : field_9
    Date.new(year, field_8, field_7) if field_9.present? && field_8.present? && field_7.present?
  rescue Date::Error
    Date.new
  end

  def ethnic_group_from_ethnic
    return nil if field_48.blank?

    case field_48
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

  def age1_known?
    return 1 if field_46 == "R"

    0
  end

  [
    { person: 2, field: :field_52 },
    { person: 3, field: :field_56 },
    { person: 4, field: :field_60 },
    { person: 5, field: :field_64 },
    { person: 6, field: :field_68 },
    { person: 7, field: :field_72 },
    { person: 8, field: :field_76 },
  ].each do |hash|
    define_method("age#{hash[:person]}_known?") do
      return 1 if public_send(hash[:field]) == "R"
      return 0 if send("person_#{hash[:person]}_present?")
    end
  end

  def details_known?(person_n)
    send("person_#{person_n}_present?") ? 0 : 1
  end

  def person_2_present?
    field_51.present? || field_52.present? || field_53.present?
  end

  def person_3_present?
    field_55.present? || field_56.present? || field_57.present?
  end

  def person_4_present?
    field_59.present? || field_60.present? || field_61.present?
  end

  def person_5_present?
    field_63.present? || field_64.present? || field_65.present?
  end

  def person_6_present?
    field_67.present? || field_68.present? || field_69.present?
  end

  def person_7_present?
    field_71.present? || field_72.present? || field_73.present?
  end

  def person_8_present?
    field_75.present? || field_76.present? || field_77.present?
  end

  def leftreg
    field_80
  end

  def housingneeds
    if field_87 == 1
      2
    elsif field_88 == 1
      3
    elsif field_87.blank? || field_87&.zero?
      1
    end
  end

  def housingneeds_type
    if field_83 == 1
      0
    elsif field_84 == 1
      1
    elsif field_85 == 1
      2
    else
      3
    end
  end

  def housingneeds_other
    return 1 if field_86 == 1
    return 0 if [field_83, field_84, field_85].include?(1)
  end

  def prevloc
    field_109
  end

  def previous_la_known
    prevloc.present? ? 1 : 0
  end

  def ppcodenk
    case field_106
    when 1
      0
    when 2
      1
    end
  end

  def ppostcode_full
    "#{field_107} #{field_108}".strip.gsub(/\s+/, " ")
  end

  def cbl
    case field_116
    when 2
      0
    when 1
      1
    end
  end

  def chr
    case field_118
    when 2
      0
    when 1
      1
    end
  end

  def cap
    case field_117
    when 2
      0
    when 1
      1
    end
  end

  def letting_allocation_unknown
    [cbl, chr, cap].all?(0) ? 1 : 0
  end

  def net_income_known
    case field_120
    when 1
      0
    when 2
      1
    when 3
      2
    end
  end

  def earnings
    field_122.round if field_122.present?
  end

  def tshortfall_known
    field_133 == 1 ? 0 : 1
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

  def majorrepairs
    mrcdate.present? ? 1 : 0
  end

  def mrcdate
    year = field_38.to_s.strip.length.between?(1, 2) ? field_38 + 2000 : field_38
    Date.new(year, field_37, field_36) if field_38.present? && field_37.present? && field_36.present?
  rescue Date::Error
    Date.new
  end

  def voiddate
    year = field_35.to_s.strip.length.between?(1, 2) ? field_35 + 2000 : field_35
    Date.new(year, field_34, field_33) if field_35.present? && field_34.present? && field_33.present?
  rescue Date::Error
    Date.new
  end

  def first_time_property_let_as_social_housing
    case rsnvac
    when 15, 16, 17
      1
    else
      0
    end
  end

  def is_carehome
    field_127.present? ? 1 : 0
  end
end
