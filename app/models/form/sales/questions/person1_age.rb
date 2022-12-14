class Form::Sales::Questions::Person1Age < ::Form::Question
  def initialize(id, hsh, page)
    super
    @check_answer_label = "Person 1’s age"
    @header = "Age"
    @type = "numeric"
    @page = page
    @width = 3
    @inferred_check_answers_value = if id == "age2"
                                      { "condition" => { "age2_known" => 1 }, "value" => "Not known" }
                                    else
                                      { "condition" => { "age3_known" => 1 }, "value" => "Not known" }
                                    end
    @hidden_in_check_answers = if id == "age2"
                                 { "depends_on" => [{ "jointpur" => 1 }] }
                               else
                                 { "depends_on" => [{ "jointpur" => 2 }] }
                               end
    @check_answers_card_number = id == "age2" ? 2 : 3
  end
end
