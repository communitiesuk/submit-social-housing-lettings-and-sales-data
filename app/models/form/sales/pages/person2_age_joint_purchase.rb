class Form::Sales::Pages::Person2AgeJointPurchase < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "person_2_age_joint_purchase"
    @header = ""
    @description = ""
    @subsection = subsection
    @depends_on = [
      { "details_known_2" => 1, "jointpur" => 1 },
    ]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Person2AgeKnown.new("age4_known", nil, self),
      Form::Sales::Questions::Person2Age.new("age4", nil, self),
    ]
  end
end
