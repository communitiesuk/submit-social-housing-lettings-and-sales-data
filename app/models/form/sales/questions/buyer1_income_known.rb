class Form::Sales::Questions::Buyer1IncomeKnown < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "income1nk"
    @copy_key = "sales.income_benefits_and_savings.income1nk"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @conditional_for = {
      "income1" => [0],
    }
    @check_answers_card_number = 1
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
    @hidden_in_check_answers = {
      "depends_on" => [
        {
          "income1nk" => 0,
        },
      ],
    }
  end

  ANSWER_OPTIONS = {
    "0" => { "value" => "Yes" },
    "1" => { "value" => "No" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 67, 2024 => 69 }.freeze
end
