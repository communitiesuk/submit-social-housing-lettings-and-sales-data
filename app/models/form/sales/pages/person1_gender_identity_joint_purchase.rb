class Form::Sales::Pages::Person1GenderIdentityJointPurchase < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "person_1_gender_identity_joint_purchase"
    @header = ""
    @description = ""
    @subsection = subsection
    @depends_on = [
      { "hholdcount" => 1, "jointpur" => 1 },
      { "hholdcount" => 2, "jointpur" => 1 },
      { "hholdcount" => 3, "jointpur" => 1 },
      { "hholdcount" => 4, "jointpur" => 1 },
    ]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Person1GenderIdentityJointPurchase.new(nil, nil, self),
    ]
  end
end
