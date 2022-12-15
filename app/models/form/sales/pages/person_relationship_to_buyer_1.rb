class Form::Sales::Pages::PersonRelationshipToBuyer1 < ::Form::Page
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
    "person_1_relationship_to_buyer_1" => 2,
    "person_2_relationship_to_buyer_1" => 3,
    "person_3_relationship_to_buyer_1" => 4,
    "person_4_relationship_to_buyer_1" => 5,
    "person_1_relationship_to_buyer_1_joint_purchase" => 3,
    "person_2_relationship_to_buyer_1_joint_purchase" => 4,
    "person_3_relationship_to_buyer_1_joint_purchase" => 5,
    "person_4_relationship_to_buyer_1_joint_purchase" => 6,
  }.freeze

  def questions
    @questions ||= [
      Form::Sales::Questions::PersonRelationshipToBuyer1.new("relat#{person_database_number(PERSON_INDEX)}", nil, self),
    ]
  end
end
