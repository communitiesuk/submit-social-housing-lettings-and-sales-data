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
      Form::Sales::Questions::Person4AgeKnown.new("age6_known", nil, self),
      Form::Sales::Questions::Person4Age.new("age6", nil, self),
    ]
  end
end
