class Form::Sales::Pages::Person4WorkingSituationJointPurchase < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "person_4_working_situation_joint_purchase"
    @header = ""
    @description = ""
    @subsection = subsection
    @depends_on = [
      { "details_known_4" => 1, "jointpur" => 1 },
    ]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Person4WorkingSituation.new("ecstat6", nil, self),
    ]
  end
end
