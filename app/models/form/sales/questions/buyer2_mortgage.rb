class Form::Sales::Questions::Buyer2Mortgage < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "inc2mort"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @check_answers_card_number = 2
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR)
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "2" => { "value" => "No" },
    "3" => { "value" => "Don’t know" },
  }.freeze

  def displayed_answer_options(_log, _user = nil)
    {
      "1" => { "value" => "Yes" },
      "2" => { "value" => "No" },
    }
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 70, 2024 => 72, 2025 => 69, 2026 => 77 }.freeze
end
