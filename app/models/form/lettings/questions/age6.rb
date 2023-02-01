class Form::Lettings::Questions::Age6 < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "age6"
    @check_answer_label = "Person 6’s age"
    @header = "Age"
    @type = "numeric"
    @width = 2
    @inferred_check_answers_value = [{ "condition" => { "age6_known" => 1 }, "value" => "Not known" }]
    @check_answers_card_number = 6
    @max = 120
    @min = 0
    @step = 1
  end
end
