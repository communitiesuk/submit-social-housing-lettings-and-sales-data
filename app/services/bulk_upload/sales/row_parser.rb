class BulkUpload::Sales::RowParser
  include ActiveModel::Model
  include ActiveModel::Attributes

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
