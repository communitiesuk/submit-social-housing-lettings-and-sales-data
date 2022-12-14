class Form::Sales::Pages::Person1WorkingSituationJointPurchase < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "person_1_working_situation_joint_purchase"
    @header = ""
    @description = ""
    @subsection = subsection
    @depends_on = [
      { "details_known_1" => 1, "jointpur" => 1 },
    ]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Person1WorkingSituation.new("ecstat3", nil, self),
    ]
  end
end
