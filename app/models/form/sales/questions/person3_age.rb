class Form::Sales::Questions::Person3Age < ::Form::Question
  def initialize(id, hsh, page)
    super
    @check_answer_label = "Person 3’s age"
    @header = "Age"
    @type = "numeric"
    @page = page
    @width = 3
    @inferred_check_answers_value = if id == "age4"
                                      { "condition" => { "age4_known" => 1 }, "value" => "Not known" }
                                    else
                                      { "condition" => { "age5_known" => 1 }, "value" => "Not known" }
                                    end
    @hidden_in_check_answers = if id == "age4"
                                 { "depends_on" => [{ "jointpur" => 1 }] }
                               else
                                 { "depends_on" => [{ "jointpur" => 2 }] }
                               end
    @check_answers_card_number = id == "age4" ? 4 : 5
  end
end
