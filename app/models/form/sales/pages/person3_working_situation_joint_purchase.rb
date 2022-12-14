class Form::Sales::Pages::Person3WorkingSituationJointPurchase < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "person_3_working_situation_joint_purchase"
    @header = ""
    @description = ""
    @subsection = subsection
    @depends_on = [
      { "details_known_3" => 1, "jointpur" => 1 },
    ]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Person3WorkingSituation.new("ecstat5", nil, self),
    ]
  end
end
