class Form::Sales::Questions::Person1Age < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "age3"
    @check_answer_label = "Person 1’s age"
    @header = "Age"
    @type = "numeric"
    @page = page
    @width = 3
    @inferred_check_answers_value = {
      "condition" => { "age3_known" => 1 },
      "value" => "Not known",
    }
    @check_answers_card_number = 3
  end
end
