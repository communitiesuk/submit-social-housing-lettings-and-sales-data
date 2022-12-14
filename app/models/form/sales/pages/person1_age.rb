class Form::Sales::Pages::Person1Age < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "person_1_age"
    @header = ""
    @description = ""
    @subsection = subsection
    @depends_on = [
      { "details_known_1" => 1, "jointpur" => 2 },
    ]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Person1AgeKnown.new("age2_known", { check_answers_card_number: 2,
                                                                  conditional_for: {
                                                                    "age2" => [0],
                                                                  },
                                                                  hidden_in_check_answers: {
                                                                    "depends_on" => [
                                                                      {
                                                                        "age2_known" => 0,
                                                                      },
                                                                      {
                                                                        "age2_known" => 1,
                                                                      },
                                                                    ],
                                                                  } }, self),
      Form::Sales::Questions::Person1Age.new("age2", { check_answers_card_number: 2,
                                                       hidden_in_check_answers: { "depends_on" => [{ "jointpur" => 1 }] },
                                                       inferred_check_answers_value: { "condition" => { "age2_known" => 1 }, "value" => "Not known" } }, self),
    ]
  end
end
