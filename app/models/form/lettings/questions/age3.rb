class Form::Lettings::Questions::Age3 < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "age3"
    @check_answer_label = "Person 3’s age"
    @header = "Age"
    @type = "numeric"
    @width = 2
    @inferred_check_answers_value = [{ "condition" => { "age3_known" => 1 }, "value" => "Not known" }]
    @check_answers_card_number = 3
    @max = 120
    @min = 0
    @step = 1
  end
end
