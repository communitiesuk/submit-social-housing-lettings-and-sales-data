class Form::Lettings::Questions::Age1 < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "age1"
    @copy_key = "lettings.household_characteristics.age1.age1"
    @type = "numeric"
    @width = 2
    @inferred_check_answers_value = [{ "condition" => { "age1_known" => 1 }, "value" => "Not known" }]
    @check_answers_card_number = 1
    @max = 120
    @min = 16
    @step = 1
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR)
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 32, 2024 => 31, 2025 => 31, 2026 => 30 }.freeze
end
