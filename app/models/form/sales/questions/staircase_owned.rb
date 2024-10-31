class Form::Sales::Questions::StaircaseOwned < ::Form::Question
  def initialize(id, hsh, page, joint_purchase:)
    super(id, hsh, page)
    @id = "stairowned"
    @check_answer_label = I18n.t("check_answer_labels.stairowned", count: joint_purchase ? 2 : 1)
    @header = I18n.t("questions.stairowned", count: joint_purchase ? 2 : 1)
    @type = "numeric"
    @width = 5
    @min = 0
    @max = 100
    @step = 0.1
    @suffix = "%"
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 78, 2024 => 80 }.freeze
end
