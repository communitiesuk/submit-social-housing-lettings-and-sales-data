class Form::Sales::Questions::StaircaseFirstTime < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "firststair"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR)
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "2" => { "value" => "No" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2025 => 93, 2026 => 101 }.freeze
end
