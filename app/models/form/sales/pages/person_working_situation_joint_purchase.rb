class Form::Sales::Pages::PersonWorkingSituationJointPurchase < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @header = ""
    @description = ""
    @subsection = subsection
    @depends_on = [
      { "details_known_#{PERSON_INDEX[id] - 2}" => 1, "jointpur" => 1 },
    ]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::PersonWorkingSituation.new("ecstat#{PERSON_INDEX[id]}", nil, self),
    ]
  end

  PERSON_INDEX = {
    "person_1_working_situation_joint_purchase" => 3,
    "person_2_working_situation_joint_purchase" => 4,
    "person_3_working_situation_joint_purchase" => 5,
    "person_4_working_situation_joint_purchase" => 6,
  }.freeze
end
