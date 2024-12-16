class Form::Sales::Questions::StaircaseFirstTime < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "firststair"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "2" => { "value" => "No" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2025 => 81 }.freeze
end
