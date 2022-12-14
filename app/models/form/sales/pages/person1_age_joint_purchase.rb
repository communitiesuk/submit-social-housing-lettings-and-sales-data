class Form::Sales::Pages::Person1AgeJointPurchase < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "person_1_age_joint_purchase"
    @header = ""
    @description = ""
    @subsection = subsection
    @depends_on = [
      { "details_known_1" => 1, "jointpur" => 1 },
    ]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Person1AgeKnown.new("age3_known", nil, self),
      Form::Sales::Questions::Person1Age.new("age3", nil, self),
    ]
  end
end
