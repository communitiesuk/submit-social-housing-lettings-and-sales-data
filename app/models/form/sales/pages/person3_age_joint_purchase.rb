class Form::Sales::Pages::Person3AgeJointPurchase < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "person_3_age_joint_purchase"
    @header = ""
    @description = ""
    @subsection = subsection
    @depends_on = [
      { "details_known_3" => 1, "jointpur" => 1 },
    ]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Person3AgeKnown.new("age5_known", nil, self),
      Form::Sales::Questions::Person3Age.new("age5", nil, self),
    ]
  end
end
