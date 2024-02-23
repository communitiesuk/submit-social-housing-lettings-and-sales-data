class Form::Sales::Questions::Age2 < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "age2"
    @check_answer_label = "Buyer 2’s age"
    @header = "Age"
    @type = "numeric"
    @width = 2
    @inferred_check_answers_value = [{
      "condition" => { "age2_known" => 1 },
      "value" => "Not known",
    }]
    @check_answers_card_number = 2
    @max = 110
    @min = 0
    @step = 1
    @question_number = QUESTION_NUMBER_FROM_YEAR.fetch(form.start_date.year, QUESTION_NUMBER_FROM_YEAR.max_by { |k, _v| k }.last)
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 28, 2024 => 30 }.freeze
end
