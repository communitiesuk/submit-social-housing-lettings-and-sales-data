class Form::Sales::Questions::Age1 < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "age1"
    @type = "numeric"
    @width = 2
    @copy_key = "sales.household_characteristics.age1.age1"
    @inferred_check_answers_value = [
      {
        "condition" => { "age1_known" => 1 },
        "value" => "Not known",
      },
      {
        "condition" => { "age1_known" => 2 },
        "value" => "Prefers not to say",
      },
    ]
    @check_answers_card_number = 1
    @min = 16
    @max = 110
    @step = 1
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 20, 2024 => 22 }.freeze
end
