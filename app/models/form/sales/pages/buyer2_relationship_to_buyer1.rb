class Form::Sales::Pages::Buyer2RelationshipToBuyer1 < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "buyer_2_relationship_to_buyer_1"
    @depends_on = [{
      "jointpur" => 1,
      "privacynotice" => 1,
    }]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Buyer2RelationshipToBuyer1.new(nil, nil, self),
    ]
  end
end
