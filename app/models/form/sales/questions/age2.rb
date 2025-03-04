class Form::Sales::Questions::Age2 < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "age2"
    @copy_key = "sales.household_characteristics.age2.buyer.age2"
    @type = "numeric"
    @width = 2
    @inferred_check_answers_value = [{
      "condition" => { "age2_known" => 1 },
      "value" => "Not known",
    }]
    @check_answers_card_number = 2
    @max = 110
    @min = 16
    @step = 1
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 28, 2024 => 30, 2025 => 28 }.freeze
end
