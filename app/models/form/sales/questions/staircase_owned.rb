class Form::Sales::Questions::StaircaseOwned < ::Form::Question
  def initialize(id, hsh, page, joint_purchase:)
    super(id, hsh, page)
    @id = "stairowned"
    @copy_key = "sales.sale_information.about_staircasing.#{joint_purchase ? 'joint_purchase' : 'not_joint_purchase'}.stairowned"
    @type = "numeric"
    @width = 5
    @min = 0
    @max = 100
    @step = 1
    @suffix = "%"
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 78, 2024 => 80 }.freeze
end
