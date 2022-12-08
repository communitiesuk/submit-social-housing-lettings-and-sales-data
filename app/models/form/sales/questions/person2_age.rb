class Form::Sales::Questions::Person2Age < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "age4"
    @check_answer_label = "Person 2’s age"
    @header = "Age"
    @type = "numeric"
    @page = page
    @width = 3
    @inferred_check_answers_value = {
      "condition" => { "age4_known" => 1 },
      "value" => "Not known"
    }
    @check_answers_card_number = 4
  end
end
