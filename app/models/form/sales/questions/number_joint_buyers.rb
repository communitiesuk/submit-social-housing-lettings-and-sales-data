class Form::Sales::Questions::NumberJointBuyers < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "jointmore"
    @copy_key = "sales.setup.jointmore"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "2" => { "value" => "No" },
    "3" => { "value" => "Don’t know" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 10, 2024 => 12 }.freeze
end
