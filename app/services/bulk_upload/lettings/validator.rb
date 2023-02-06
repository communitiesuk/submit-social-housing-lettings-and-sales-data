require "csv"

class BulkUpload::Lettings::Validator
  COLUMN_PERCENTAGE_ERROR_THRESHOLD = 0.6
  COLUMN_ABSOLUTE_ERROR_THRESHOLD = 16

  include ActiveModel::Validations

  QUESTIONS = {
    field_1: "What is the letting type?",
    field_2: "This question has been removed",
    field_3: "This question has been removed",
    field_4: "Management group code",
    field_5: "Scheme code",
    field_6: "This question has been removed",
    field_7: "What is the tenant code?",
    field_8: "Is this a starter tenancy?",
    field_9: "What is the tenancy type?",
    field_10: "If 'Other', what is the tenancy type?",
    field_11: "What is the length of the fixed-term tenancy to the nearest year?",
    field_12: "Age of Person 1",
    field_13: "Age of Person 2",
    field_14: "Age of Person 3",
    field_15: "Age of Person 4",
    field_16: "Age of Person 5",
    field_17: "Age of Person 6",
    field_18: "Age of Person 7",
    field_19: "Age of Person 8",
    field_20: "Gender identity of Person 1",
    field_21: "Gender identity of Person 2",
    field_22: "Gender identity of Person 3",
    field_23: "Gender identity of Person 4",
    field_24: "Gender identity of Person 5",
    field_25: "Gender identity of Person 6",
    field_26: "Gender identity of Person 7",
    field_27: "Gender identity of Person 8",
    field_28: "Relationship to Person 1 for Person 2",
    field_29: "Relationship to Person 1 for Person 3",
    field_30: "Relationship to Person 1 for Person 4",
    field_31: "Relationship to Person 1 for Person 5",
    field_32: "Relationship to Person 1 for Person 6",
    field_33: "Relationship to Person 1 for Person 7",
    field_34: "Relationship to Person 1 for Person 8",
    field_35: "Working situation of Person 1",
    field_36: "Working situation of Person 2",
    field_37: "Working situation of Person 3",
    field_38: "Working situation of Person 4",
    field_39: "Working situation of Person 5",
    field_40: "Working situation of Person 6",
    field_41: "Working situation of Person 7",
    field_42: "Working situation of Person 8",
    field_43: "What is the lead tenant's ethnic group?",
    field_44: "What is the lead tenant's nationality?",
    field_45: "Does anybody in the household have links to the UK armed forces?",
    field_46: "Was the person seriously injured or ill as a result of serving in the UK armed forces?",
    field_47: "Is anybody in the household pregnant?",
    field_48: "Is the tenant likely to be receiving benefits related to housing?",
    field_49: "How much of the household's income is from Universal Credit, state pensions or benefits?",
    field_50: "How much income does the household have in total?",
    field_51: "Do you know the household's income?",
    field_52: "What is the tenant's main reason for the household leaving their last settled home?",
    field_53: "If 'Other', what was the main reason for leaving their last settled home?",
    field_54: "This question has been removed",
    field_55: "Does anybody in the household have any disabled access needs?",
    field_56: "Does anybody in the household have any disabled access needs?",
    field_57: "Does anybody in the household have any disabled access needs?",
    field_58: "Does anybody in the household have any disabled access needs?",
    field_59: "Does anybody in the household have any disabled access needs?",
    field_60: "Does anybody in the household have any disabled access needs?",
    field_61: "Where was the household immediately before this letting?",
    field_62: "What is the local authority of the household's last settled home?",
    field_63: "Part 1 of postcode of last settled home",
    field_64: "Part 2 of postcode of last settled home",
    field_65: "Do you know the postcode of last settled home?",
    field_66: "How long has the household continuously lived in the local authority area of the new letting?",
    field_67: "How long has the household been on the waiting list for the new letting?",
    field_68: "Was the tenant homeless directly before this tenancy?",
    field_69: "Was the household given 'reasonable preference' by the local authority?",
    field_70: "Reasonable preference. They were homeless or about to lose their home (within 56 days)",
    field_71: "Reasonable preference. They were living in insanitary, overcrowded or unsatisfactory housing",
    field_72: "Reasonable preference. They needed to move on medical and welfare grounds (including a disability)",
    field_73: "Reasonable preference. They needed to move to avoid hardship to themselves or others",
    field_74: "Reasonable preference. Don't know",
    field_75: "Was the letting made under any of the following allocations systems?",
    field_76: "Was the letting made under any of the following allocations systems?",
    field_77: "Was the letting made under any of the following allocations systems?",
    field_78: "What was the source of referral for this letting?",
    field_79: "How often does the household pay rent and other charges?",
    field_80: "What is the basic rent?",
    field_81: "What is the service charge?",
    field_82: "What is the personal service charge?",
    field_83: "What is the support charge?",
    field_84: "Total Charge",
    field_85: "If this is a care home, how much does the household pay every [time period]?",
    field_86: "Does the household pay rent or other charges for the accommodation?",
    field_87: "After the household has received any housing-related benefits, will they still need to pay basic rent and other charges?",
    field_88: "What do you expect the outstanding amount to be?",
    field_89: "What is the void or renewal date?",
    field_90: "What is the void or renewal date?",
    field_91: "What is the void or renewal date?",
    field_92: "What date were major repairs completed on?",
    field_93: "What date were major repairs completed on?",
    field_94: "What date were major repairs completed on?",
    field_95: "This question has been removed",
    field_96: "What date did the tenancy start?",
    field_97: "What date did the tenancy start?",
    field_98: "What date did the tenancy start?",
    field_99: "Since becoming available, how many times has the property been previously offered?",
    field_100: "What is the property reference?",
    field_101: "How many bedrooms does the property have?",
    field_102: "What type of unit is the property?",
    field_103: "Which type of building is the property?",
    field_104: "Is the property built or adapted to wheelchair-user standards?",
    field_105: "What type was the property most recently let as?",
    field_106: "What is the reason for the property being vacant?",
    field_107: "What is the local authority of the property?",
    field_108: "Part 1 of postcode of the property",
    field_109: "Part 2 of postcode of the property",
    field_110: "This question has been removed",
    field_111: "Which organisation owns this property?",
    field_112: "Username field",
    field_113: "Which organisation manages this property?",
    field_114: "Is the person still serving in the UK armed forces?",
    field_115: "This question has been removed",
    field_116: "How often does the household receive income?",
    field_117: "Is this letting sheltered accommodation?",
    field_118: "Does anybody in the household have a physical or mental health condition (or other illness) expected to last for 12 months or more?",
    field_119: "Vision, for example blindness or partial sight",
    field_120: "Hearing, for example deafness or partial hearing",
    field_121: "Mobility, for example walking short distances or climbing stairs",
    field_122: "Dexterity, for example lifting and carrying objects, using a keyboard",
    field_123: "Learning or understanding or concentrating",
    field_124: "Memory",
    field_125: "Mental health",
    field_126: "Stamina or breathing or fatigue",
    field_127: "Socially or behaviourally, for example  associated with autism spectral disorder (ASD) which includes Aspergers' or attention deficit hyperactivity disorder (ADHD)",
    field_128: "Other",
    field_129: "Is this letting a London Affordable Rent letting?",
    field_130: "Which type of Intermediate Rent is this letting?",
    field_131: "Which 'Other' type of Intermediate Rent is this letting?",
    field_132: "Data Protection",
    field_133: "Is this a joint tenancy?",
    field_134: "Is this letting a renewal?",
  }.freeze

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
          error: error.message,
          tenant_code: row_parser.field_7,
          property_ref: row_parser.field_100,
          row:,
          cell: "#{cols[field_number_for_attribute(error.attribute) - col_offset + 1]}#{row}",
          col: cols[field_number_for_attribute(error.attribute) - col_offset + 1],
        )
      end
    end
  end

  def create_logs?
    # return false if any_setup_sections_incomplete?
    return false if over_column_error_threshold?
    return false if duplicate_log_already_exists?

    row_parsers.all? { |row_parser| row_parser.log.valid? }
  end

  def self.question_for_field(field)
    QUESTIONS[field]
  end

private

  def any_setup_sections_incomplete?
    row_parsers.any? { |row_parser| row_parser.log.form.setup_sections[0].subsections[0].is_incomplete?(row_parser.log) }
  end

  def over_column_error_threshold?
    fields = ("field_1".."field_134").to_a
    percentage_threshold = (row_parsers.size * COLUMN_PERCENTAGE_ERROR_THRESHOLD).ceil

    fields.any? do |field|
      count = row_parsers.count { |row_parser| row_parser.errors[field].present? }

      next if count < COLUMN_ABSOLUTE_ERROR_THRESHOLD

      count > percentage_threshold
    end
  end

  def duplicate_log_already_exists?
    fields = ["lettype", "beds"]

    fields.all? do |field|
      count = row_parsers.count { |row_parser| LettingsLog.where("#{field}": row_parser.attributes[field]).present? }

      count > 0
    end
  end

  def csv_parser
    @csv_parser ||= BulkUpload::Lettings::CsvParser.new(path:)
  end

  def row_offset
    csv_parser.row_offset
  end

  def col_offset
    csv_parser.col_offset
  end

  def field_number_for_attribute(attribute)
    attribute.to_s.split("_").last.to_i
  end

  def cols
    csv_parser.cols
  end

  def row_parsers
    return @row_parsers if @row_parsers

    @row_parsers = csv_parser.row_parsers

    @row_parsers.each do |row_parser|
      row_parser.bulk_upload = bulk_upload
    end

    @row_parsers
  end

  def rows
    csv_parser.rows
  end

  def body_rows
    csv_parser.body_rows
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

    errors.add(:file, :max_row_size) if max_row_size > 136
  end

  def halt_validations!
    @halt_validations = true
  end

  def halt_validations?
    @halt_validations ||= false
  end
end
