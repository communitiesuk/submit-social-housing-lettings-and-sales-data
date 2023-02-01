class Form::Lettings::Questions::Age7 < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "age7"
    @check_answer_label = "Person 7’s age"
    @header = "Age"
    @type = "numeric"
    @width = 2
    @inferred_check_answers_value = [{ "condition" => { "age7_known" => 1 }, "value" => "Not known" }]
    @check_answers_card_number = 7
    @max = 120
    @min = 0
    @step = 1
  end
end
