class Form::Sales::Pages::Person4Age < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "person_4_age"
    @header = ""
    @description = ""
    @subsection = subsection
    @depends_on = [
      { "details_known_4" => 1, "jointpur" => 2 },
    ]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Person4AgeKnown.new("age5_known", { check_answers_card_number: 5,
                                                                  conditional_for: {
                                                                    "age5" => [0],
                                                                  },
                                                                  hidden_in_check_answers: {
                                                                    "depends_on" => [
                                                                      {
                                                                        "age5_known" => 0,
                                                                      },
                                                                      {
                                                                        "age5_known" => 1,
                                                                      },
                                                                    ],
                                                                  } }, self),
      Form::Sales::Questions::Person4Age.new("age5", { check_answers_card_number: 5,
                                                       hidden_in_check_answers: { "depends_on" => [{ "jointpur" => 1 }] },
                                                       inferred_check_answers_value: { "condition" => { "age5_known" => 1 }, "value" => "Not known" } }, self),
    ]
  end
end
