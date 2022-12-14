class Form::Sales::Pages::Person2WorkingSituationJointPurchase < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "person_2_working_situation_joint_purchase"
    @header = ""
    @description = ""
    @subsection = subsection
    @depends_on = [
      { "details_known_2" => 1, "jointpur" => 1 },
    ]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Person2WorkingSituation.new("ecstat4", nil, self),
    ]
  end
end
