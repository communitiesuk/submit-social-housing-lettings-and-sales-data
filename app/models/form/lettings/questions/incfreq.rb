class Form::Lettings::Questions::Incfreq < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "incfreq"
    @copy_key = "lettings.income_and_benefits.income_amount.incfreq"
    @type = "radio"
    @check_answers_card_number = 0
    @answer_options = ANSWER_OPTIONS
    @hidden_in_check_answers = true
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year]
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Weekly" },
    "2" => { "value" => "Monthly" },
    "3" => { "value" => "Yearly" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 87, 2024 => 86, 2025 => 86, 2026 => 85 }.freeze
end
