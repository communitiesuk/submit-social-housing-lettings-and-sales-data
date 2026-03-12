class Form::Sales::Questions::NumberOfOthersInProperty < ::Form::Question
  def initialize(id, hsh, page, joint_purchase:)
    super(id, hsh, page)
    @id = "hholdcount"
    @copy_key = joint_purchase ? "sales.household_characteristics.hholdcount.joint_purchase" : "sales.household_characteristics.hholdcount.not_joint_purchase"
    @type = "numeric"
    @width = 2
    @min = form.start_year_2026_or_later? ? 1 : 0
    @max = 15
    @step = 1
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR)
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 35, 2024 => 37, 2025 => 35, 2026 => 38 }.freeze
end
