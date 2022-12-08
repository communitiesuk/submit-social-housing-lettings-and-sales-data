class Form::Sales::Questions::Person3Age < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "age5"
    @check_answer_label = "Person 3’s age"
    @header = "Age"
    @type = "numeric"
    @page = page
    @width = 3
    @inferred_check_answers_value = {
      "condition" => { "age5_known" => 1 },
      "value" => "Not known"
    }
    @check_answers_card_number = 5
  end
end
