class Form::Sales::Pages::Person2Age < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "person_2_age"
    @header = ""
    @description = ""
    @subsection = subsection
    @depends_on = [
      { "details_known_2" => 1, "jointpur" => 2 },
    ]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Person2AgeKnown.new("age3_known", { check_answers_card_number: 3,
                                                                  conditional_for: {
                                                                    "age3" => [0],
                                                                  },
                                                                  hidden_in_check_answers: {
                                                                    "depends_on" => [
                                                                      {
                                                                        "age3_known" => 0,
                                                                      },
                                                                      {
                                                                        "age3_known" => 1,
                                                                      },
                                                                    ],
                                                                  } }, self),
      Form::Sales::Questions::Person2Age.new("age3", { check_answers_card_number: 3,
                                                       hidden_in_check_answers: { "depends_on" => [{ "jointpur" => 1 }] },
                                                       inferred_check_answers_value: { "condition" => { "age3_known" => 1 }, "value" => "Not known" } }, self),
    ]
  end
end
