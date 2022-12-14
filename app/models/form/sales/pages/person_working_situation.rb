class Form::Sales::Pages::PersonWorkingSituation < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @header = ""
    @description = ""
    @subsection = subsection
    @depends_on = [
      { "details_known_#{person_display_number}" => 1, "jointpur" => joint_purchase? ? 1 : 2 },
    ]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::PersonWorkingSituation.new("ecstat#{person_database_number}", nil, self),
    ]
  end

  def person_database_number
    PERSON_INDEX[id]
  end

  def person_display_number
    joint_purchase? ? PERSON_INDEX[id] - 2 : PERSON_INDEX[id] - 1
  end

  def joint_purchase?
    id.include?("_joint_purchase")
  end

  PERSON_INDEX = {
    "person_1_working_situation" => 2,
    "person_2_working_situation" => 3,
    "person_3_working_situation" => 4,
    "person_4_working_situation" => 5,
    "person_1_working_situation_joint_purchase" => 3,
    "person_2_working_situation_joint_purchase" => 4,
    "person_3_working_situation_joint_purchase" => 5,
    "person_4_working_situation_joint_purchase" => 6,
  }.freeze
end
