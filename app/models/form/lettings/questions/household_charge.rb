class Form::Lettings::Questions::HouseholdCharge < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "household_charge"
    @type = "radio"
    @check_answers_card_number = 0
    @answer_options = ANSWER_OPTIONS
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year]
  end

  ANSWER_OPTIONS = { "0" => { "value" => "Yes" }, "1" => { "value" => "No" } }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 91, 2024 => 90, 2025 => 90, 2026 => 89 }.freeze
end
