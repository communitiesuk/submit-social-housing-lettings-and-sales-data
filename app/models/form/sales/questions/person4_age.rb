class Form::Sales::Questions::Person4Age < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "age6"
    @check_answer_label = "Person 4’s age"
    @header = "Age"
    @type = "numeric"
    @page = page
    @width = 3
    @inferred_check_answers_value = {
      "condition" => { "age6_known" => 1 },
      "value" => "Not known"
    }
    @check_answers_card_number = 6
  end
end
