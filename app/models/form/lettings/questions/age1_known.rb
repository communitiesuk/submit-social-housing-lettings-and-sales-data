class Form::Lettings::Questions::Age1Known < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "age1_known"
    @copy_key = "lettings.household_characteristics.age1.age1_known"
    @type = "radio"
    @check_answers_card_number = 1
    @answer_options = ANSWER_OPTIONS
    @conditional_for = { "age1" => [0] }
    @hidden_in_check_answers = { "depends_on" => [{ "age1_known" => 0 }, { "age1_known" => 1 }] }
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year]
  end

  ANSWER_OPTIONS = { "0" => { "value" => "Yes" }, "1" => { "value" => "No" } }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 32, 2024 => 31, 2025 => 31, 2026 => 31 }.freeze
end
