class Form::Sales::Pages::Person1RelationshipToBuyer1JointPurchase < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "person_1_relationship_to_buyer_1_joint_purchase"
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
      Form::Sales::Questions::Person1RelationshipToBuyer1JointPurchase.new(nil, nil, self),
    ]
  end
end
