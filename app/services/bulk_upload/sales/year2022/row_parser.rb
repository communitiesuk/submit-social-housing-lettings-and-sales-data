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
    field_7: "Age of Buyer 1",
    field_8: "Age of person 2",
    field_9: "Age of person 3",
    field_10: "Age of person 4",
    field_11: "Age of person 5",
    field_12: "Age of person 6",
    field_13: "Gender identity of Buyer 1",
    field_14: "Gender identity of person 2",
    field_15: "Gender identity of person 3",
    field_16: "Gender identity of person 4",
    field_17: "Gender identity of person 5",
    field_18: "Gender identity of person 6",
    field_19: "Relationship to Buyer 1 for person 2",
    field_20: "Relationship to Buyer 1 for person 3",
    field_21: "Relationship to Buyer 1 for person 4",
    field_22: "Relationship to Buyer 1 for person 5",
    field_23: "Relationship to Buyer 1 for person 6",
    field_24: "Working situation of Buyer 1",
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

  attribute :field_1, :string
  attribute :field_2, :integer
  attribute :field_3, :integer
  attribute :field_4, :integer
  attribute :field_5
  attribute :field_6, :integer
  attribute :field_7, :integer
  attribute :field_8, :integer
  attribute :field_9, :integer
  attribute :field_10, :integer
  attribute :field_11, :integer
  attribute :field_12, :integer
  attribute :field_13, :string
  attribute :field_14, :string
  attribute :field_15, :string
  attribute :field_16, :string
  attribute :field_17, :string
  attribute :field_18, :string
  attribute :field_19, :string
  attribute :field_20, :integer
  attribute :field_21, :integer
  attribute :field_22, :integer
  attribute :field_23, :integer
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
  attribute :field_92, :integer
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

  # validates :field_1, presence: true, numericality: { in: (1..12) }
  # validates :field_4, numericality: { in: (1..999), allow_blank: true }
  # validates :field_4, presence: true, if: :field_4_presence_check

  validate :validate_possible_answers

  # delegate :valid?, to: :native_object
  # delegate :errors, to: :native_object

  def self.question_for_field(field)
    QUESTIONS[field]
  end

private

  def native_object
    @native_object ||= SalesLog.new(attributes_for_log)
  end

  def field_mapping
    {
      field_117: :buy1livein,
    }
  end

  def validate_possible_answers
    field_mapping.each do |field, attribute|
      possible_answers = FormHandler.instance.current_sales_form.questions.find { |q| q.id == attribute.to_s }.answer_options.keys

      unless possible_answers.include?(public_send(field))
        errors.add(field, "Value supplied is not one of the permitted values")
      end
    end
  end

  def attributes_for_log
    hash = field_mapping.invert
    attributes = {}

    hash.map do |k, v|
      attributes[k] = public_send(v)
    end

    attributes
  end

  # def field_4_presence_check
  #   [1, 3, 5, 7, 9, 11].include?(field_1)
  # end
end
