class Form::Lettings::Questions::Age8 < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "age8"
    @check_answer_label = "Person 8’s age"
    @header = "Age"
    @type = "numeric"
    @width = 2
    @inferred_check_answers_value = [{ "condition" => { "age8_known" => 1 }, "value" => "Not known" }]
    @check_answers_card_number = 8
    @max = 120
    @min = 0
    @step = 1
  end
end
