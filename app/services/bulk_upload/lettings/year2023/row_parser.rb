class BulkUpload::Lettings::Year2023::RowParser
  include ActiveModel::Model
  include ActiveModel::Attributes

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
    field_23: "Part 1 of the property's postcode",
    field_24: "Part 2 of the property's postcode",
    field_25: "What is the property's local authority?",
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
    field_45: "Has tenant seen the DLUHC privacy notice?",
    field_46: "What is the lead tenant's age?",
    field_47: "Which of these best describes the lead tenant's gender identity?",
    field_48: "Which of these best describes the lead tenant's ethnic background?",
    field_49: "What is the lead tenant's nationality?",
    field_50: "Which of these best describes the lead tenant's working situation?",
    field_51: "What is person 2's relationship to the lead tenant?",
    field_52: "What is person 2's age?",
    field_53: "Which of these best describes person 2's gender identity?",
    field_54: "Which of these best describes person 2's working situation?",
    field_55: "What is person 3's relationship to the lead tenant?",
    field_56: "What is person 3's age?",
    field_57: "Which of these best describes person 3's gender identity?",
    field_58: "Which of these best describes person 3's working situation?",
    field_59: "What is person 4's relationship to the lead tenant?",
    field_60: "What is person 4's age?",
    field_61: "Which of these best describes person 4's gender identity?",
    field_62: "Which of these best describes person 4's working situation?",
    field_63: "What is person 5's relationship to the lead tenant?",
    field_64: "What is person 5's age?",
    field_65: "Which of these best describes person 5's gender identity?",
    field_66: "Which of these best describes person 5's working situation?",
    field_67: "What is person 6's relationship to the lead tenant?",
    field_68: "What is person 6's age?",
    field_69: "Which of these best describes person 6's gender identity?",
    field_70: "Which of these best describes person 6's working situation?",
    field_71: "What is person 7's relationship to the lead tenant?",
    field_72: "What is person 7's age?",
    field_73: "Which of these best describes person 7's gender identity?",
    field_74: "Which of these best describes person 7's working situation?",
    field_75: "What is person 8's relationship to the lead tenant?",
    field_76: "What is person 8's age?",
    field_77: "Which of these best describes person 8's gender identity?",
    field_78: "Which of these best describes person 8's working situation?",
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
    field_90: "Does this person's condition affect their dexterity?",
    field_91: "Does this person's condition affect their learning or understanding or concentrating?",
    field_92: "Does this person's condition affect their hearing?",
    field_93: "Does this person's condition affect their memory?",
    field_94: "Does this person's condition affect their mental health?",
    field_95: "Does this person's condition affect their mobility?",
    field_96: "Does this person's condition affect them socially or behaviourally?",
    field_97: "Does this person's condition affect their stamina or breathing or fatigue?",
    field_98: "Does this person's condition affect their vision?",
    field_99: "Does this person's condition affect them in another way?",
    field_100: "How long has the household continuously lived in the local authority area of the new letting?",
    field_101: "How long has the household been on the local authority waiting list for the new letting?",
    field_102: "What is the tenant’s main reason for the household leaving their last settled home?",
    field_103: "If 'Other', what was the main reason for leaving their last settled home?",
    field_104: "Where was the household immediately before this letting?",
    field_105: "Did the household experience homelessness immediately before this letting?",
    field_106: "Do you know the postcode of the household's last settled home?",
    field_107: "What is the postcode of the household's last settled home?",
    field_108: "What is the postcode of the household's last settled home?",
    field_109: "What is the local authority of the household's last settled home?",
    field_110: "Was the household given 'reasonable preference' by the local authority?",
    field_111: "Reasonable preference reason They were homeless or about to lose their home (within 56 days)",
    field_112: "Reasonable preference reason They were living in insanitary, overcrowded or unsatisfactory housing",
    field_113: "Reasonable preference reason They needed to move on medical and welfare reasons (including disability)",
    field_114: "Reasonable preference reason They needed to move to avoid hardship to themselves or others",
    field_115: "Reasonable preference reason Don't know",
    field_116: "How was this letting allocated?",
    field_117: "How was this letting allocated?",
    field_118: "How was this letting allocated?",
    field_119: "What was the source of referral for this letting?",
    field_120: "Do you know the household's combined total income after tax?",
    field_121: "How often does the household receive income?",
    field_122: "How much income does the household have in total?",
    field_123: "Is the tenant likely to be receiving any of these housing-related benefits?",
    field_124: "How much of the household's income is from Universal Credit, state pensions or benefits?",
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
  attribute :field_60, :integer
  attribute :field_61, :string
  attribute :field_62, :integer
  attribute :field_63, :string
  attribute :field_64, :integer
  attribute :field_65, :string
  attribute :field_66, :integer
  attribute :field_67, :string
  attribute :field_68, :integer
  attribute :field_69, :string
  attribute :field_70, :integer
  attribute :field_71, :string
  attribute :field_72, :integer
  attribute :field_73, :string
  attribute :field_74, :integer
  attribute :field_75, :string
  attribute :field_76, :integer
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
  attribute :field_122, :integer
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

  def self.question_for_field(field)
    QUESTIONS[field]
  end

  def blank_row?
    attribute_set
      .to_hash
      .reject { |k, _| %w[bulk_upload block_log_creation field_blank].include?(k) }
      .values
      .compact
      .empty?
  end

private

  def attribute_set
    @attribute_set ||= instance_variable_get(:@attributes)
  end
end
