class Form::Sales::Pages::Person4AgeJointPurchase < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "person_4_age_joint_purchase"
    @header = ""
    @description = ""
    @subsection = subsection
    @depends_on = [
      { "details_known_4" => 1, "jointpur" => 1 },
    ]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Person4AgeKnown.new("age6_known", { check_answers_card_number: 6,
                                                                  conditional_for: {
                                                                    "age6" => [0],
                                                                  },
                                                                  hidden_in_check_answers: {
                                                                    "depends_on" => [
                                                                      {
                                                                        "age6_known" => 0,
                                                                      },
                                                                      {
                                                                        "age6_known" => 1,
                                                                      },
                                                                    ],
                                                                  } }, self),
      Form::Sales::Questions::Person4Age.new("age6", { check_answers_card_number: 6,
                                                       hidden_in_check_answers: { "depends_on" => [{ "jointpur" => 2 }] },
                                                       inferred_check_answers_value: { "condition" => { "age6_known" => 1 }, "value" => "Not known" } }, self),
    ]
  end
end
