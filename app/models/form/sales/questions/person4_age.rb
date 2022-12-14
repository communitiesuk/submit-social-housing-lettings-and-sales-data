class Form::Sales::Questions::Person4Age < ::Form::Question
  def initialize(id, hsh, page)
    super
    @check_answer_label = "Person 4’s age"
    @header = "Age"
    @type = "numeric"
    @page = page
    @width = 3
    @inferred_check_answers_value = if id == "age5"
                                      { "condition" => { "age5_known" => 1 }, "value" => "Not known" }
                                    else
                                      { "condition" => { "age6_known" => 1 }, "value" => "Not known" }
                                    end
    @hidden_in_check_answers = if id == "age5"
                                 { "depends_on" => [{ "jointpur" => 1 }] }
                               else
                                 { "depends_on" => [{ "jointpur" => 2 }] }
                               end
    @check_answers_card_number = id == "age5" ? 5 : 6
  end
end
