class Form::Sales::Pages::Buyer2RelationshipToBuyer1YesNo < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "buyer_2_relationship_to_buyer_1"
    @copy_key = "sales.household_characteristics.relat2.buyer"
    @depends_on = [{ "joint_purchase?" => true }]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Buyer2RelationshipToBuyer1YesNo.new(nil, nil, self),
    ]
  end
end
