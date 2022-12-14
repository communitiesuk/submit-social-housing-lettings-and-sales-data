class Form::Sales::Questions::Person2Age < ::Form::Question
  def initialize(id, hsh, page)
    super
    @check_answer_label = "Person 2’s age"
    @header = "Age"
    @type = "numeric"
    @page = page
    @width = 3
    @inferred_check_answers_value = if id == "age3"
                                      { "condition" => { "age3_known" => 1 }, "value" => "Not known" }
                                    else
                                      { "condition" => { "age4_known" => 1 }, "value" => "Not known" }
                                    end
    @hidden_in_check_answers = if id == "age3"
                                 { "depends_on" => [{ "jointpur" => 1 }] }
                               else
                                 { "depends_on" => [{ "jointpur" => 2 }] }
                               end
    @check_answers_card_number = id == "age3" ? 3 : 4
  end
end
