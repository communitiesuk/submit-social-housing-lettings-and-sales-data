class Form::Sales::Questions::Buyer2Mortgage < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "inc2mort"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @check_answers_card_number = 2
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
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

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 70, 2024 => 72, 2025 => 69 }.freeze
end
