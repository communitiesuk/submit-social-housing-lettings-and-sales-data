class Form::Sales::Questions::StaircaseOwned < ::Form::Question
  def initialize(id, hsh, page, joint_purchase:)
    super(id, hsh, page)
    @id = "stairowned"
    @copy_key = "sales.sale_information.about_staircasing.stairowned.#{joint_purchase ? 'joint_purchase' : 'not_joint_purchase'}"
    @type = "numeric"
    @width = 5
    @min = 0
    @max = 100
    @step = 0.1
    @suffix = "%"
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR)
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 78, 2024 => 80, 2025 => 91, 2026 => 99 }.freeze
end
