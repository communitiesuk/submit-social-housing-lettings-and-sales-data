class Form::Sales::Pages::Person1GenderIdentityJointPurchase < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "person_1_gender_identity_joint_purchase"
    @header = ""
    @description = ""
    @subsection = subsection
    @depends_on = [
      { "details_known_1" => 1, "jointpur" => 1 },
    ]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Person1GenderIdentity.new("sex3", { check_answers_card_number: 3 }, self),
    ]
  end
end
