class Form::Sales::Pages::Buyer2RelationshipToBuyer1 < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "buyer_2_relationship_to_buyer_1"
    @depends_on = [
      {
        "joint_purchase?" => true,
        "buyer_has_seen_privacy_notice?" => true,
      },
      {
        "joint_purchase?" => true,
        "buyer_not_interviewed?" => true,
      },
    ]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Buyer2RelationshipToBuyer1.new(nil, nil, self),
    ]
  end
end
