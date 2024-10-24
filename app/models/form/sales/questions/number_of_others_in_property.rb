class Form::Sales::Questions::NumberOfOthersInProperty < ::Form::Question
  def initialize(id, hsh, page, joint_purchase:)
    super(id, hsh, page)
    @id = "hholdcount"
    @copy_key = joint_purchase ? "sales.household_characteristics.hholdcount.joint_purchase" : "sales.household_characteristics.hholdcount.not_joint_purchase"
    @type = "numeric"
    @width = 2
    @min = 0
    @max = 15
    @step = 1
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 35, 2024 => 37 }.freeze
end
