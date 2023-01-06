class BulkUpload::Lettings::RowParser
  include ActiveModel::Model
  include ActiveModel::Attributes

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
      field = field_for_attribute(error.attribute)
      errors.add(field, error.type)
    end
  end

private

  def questions
    log.form.subsections.flat_map { |ss| ss.applicable_questions(log) }
  end

  def log
    @log ||= LettingsLog.new(attributes_for_log)
  end

  def field_for_attribute(attribute)
    field_mapping.find { |h| h[:attribute] == attribute }[:name]
  end

  def validate_nulls
    field_mapping.each do |hash|
      question = questions.find { |q| q.id == hash[:question_id] }

      next unless question

      completed = question.completed?(log)

      unless completed
        errors.add(hash[:name], :blank)
      end
    end
  end

  def field_mapping
    [
      { name: :field_1, attribute: :lettype },
      { name: :field_7, attribute: :tenancycode, question_id: "tenancycode" },
      { name: :field_134, attribute: :renewal },
    ]
  end

  def attributes_for_log
    attributes = {}

    field_mapping.map do |h|
      attributes[h[:attribute]] = public_send(h[:name])
    end

    attributes[:scheme] = scheme

    attributes
  end

  def scheme
    @scheme ||= Scheme.find_by(old_visible_id: field_4)
  end
end
