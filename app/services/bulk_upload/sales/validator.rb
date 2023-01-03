class BulkUpload::Sales::Validator
  include ActiveModel::Validations

  QUESTIONS = {
    field_1: "What is the purchaser code?",
    field_2: "What is the day of the sale completion date? - DD",
    field_3: "What is the month of the sale completion date? - MM",
    field_4: "What is the year of the sale completion date? - YY",
    field_5: "This question has been removed",
    field_6: "Was the buyer interviewed for any of the answers you will provide on this log?",
    field_7: "Age of Buyer 1",
    field_8: "Age of Person 2",
    field_9: "Age of Person 3",
    field_10: "Age of Person 4",
    field_11: "Age of Person 5",
    field_12: "Age of Person 6",
    field_13: "Gender identity of Buyer 1",
    field_14: "Gender identity of Person 2",
    field_15: "Gender identity of Person 3",
    field_16: "Gender identity of Person 4",
    field_17: "Gender identity of Person 5",
    field_18: "Gender identity of Person 6",
    field_19: "Relationship to Buyer 1 for Person 2",
    field_20: "Relationship to Buyer 1 for Person 3",
    field_21: "Relationship to Buyer 1 for Person 4",
    field_22: "Relationship to Buyer 1 for Person 5",
    field_23: "Relationship to Buyer 1 for Person 6",
    field_24: "Working situation of Buyer 1",
    field_25: "Working situation of Person 2",
    field_26: "Working situation of Person 3",
    field_27: "Working situation of Person 4",
    field_28: "Working situation of Person 5",
    field_29: "Working situation of Person 6",
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

  def self.question_for_field(field)
    QUESTIONS[field]
  end

  attr_reader :bulk_upload, :path

  validate :validate_file_not_empty
  validate :validate_max_columns

  def initialize(bulk_upload:, path:)
    @bulk_upload = bulk_upload
    @path = path
  end

  def call
    row_parsers.each_with_index do |row_parser, index|
      row_parser.valid?

      row = index + row_offset + 1

      row_parser.errors.each do |error|
        bulk_upload.bulk_upload_errors.create!(
          field: error.attribute,
          error: error.type,
          purchaser_code: row_parser.field_1,
          row:,
          cell: "#{cols[field_number_for_attribute(error.attribute) + col_offset - 1]}#{row}",
        )
      end
    end
  end

private

  def field_number_for_attribute(attribute)
    attribute.to_s.split("_").last.to_i
  end

  def rows
    @rows ||= CSV.read(path, row_sep:)
  end

  def body_rows
    rows[row_offset..]
  end

  def row_offset
    5
  end

  def col_offset
    1
  end

  def cols
    @cols ||= ("A".."DV").to_a
  end

  def row_parsers
    @row_parsers ||= body_rows.map do |row|
      stripped_row = row[col_offset..]
      headers = ("field_1".."field_125").to_a
      hash = Hash[headers.zip(stripped_row)]

      BulkUpload::Sales::RowParser.new(hash)
    end
  end

  def row_sep
    "\r\n"
    # "\n"
  end

  def validate_file_not_empty
    if File.size(path).zero?
      errors.add(:file, :blank)

      halt_validations!
    end
  end

  def validate_max_columns
    return if halt_validations?

    max_row_size = rows.map(&:size).max

    errors.add(:file, :max_row_size) if max_row_size > 126
  end

  def halt_validations!
    @halt_validations = true
  end

  def halt_validations?
    @halt_validations ||= false
  end
end
