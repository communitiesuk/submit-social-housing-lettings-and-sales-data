class Form::Sales::Pages::PersonAge < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @header = ""
    @description = ""
    @subsection = subsection
    @depends_on = [
      { "details_known_#{person_display_number(PERSON_INDEX)}" => 1, "jointpur" => joint_purchase? ? 1 : 2 },
    ]
  end

  PERSON_INDEX = {
    "person_1_age" => 2,
    "person_2_age" => 3,
    "person_3_age" => 4,
    "person_4_age" => 5,
    "person_1_age_joint_purchase" => 3,
    "person_2_age_joint_purchase" => 4,
    "person_3_age_joint_purchase" => 5,
    "person_4_age_joint_purchase" => 6,
  }.freeze

  def questions
    @questions ||= [
      Form::Sales::Questions::PersonAgeKnown.new("age#{person_database_number(PERSON_INDEX)}_known", nil, self),
      Form::Sales::Questions::PersonAge.new("age#{person_database_number(PERSON_INDEX)}", nil, self),
    ]
  end
end
