class Form::Sales::Pages::Buyer2RelationshipToBuyer1 < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "buyer_2_relationship_to_buyer_1"
    @header = ""
    @description = ""
    @subsection = subsection
    @depends_on = [{
      "jointpur" => 1,
    }]

  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Buyer2RelationshipToBuyer1.new(nil, nil, self),
      Form::Sales::Questions::OtherBuyer2RelationshipToBuyer1.new(nil, nil, self),
    ]
  end
end
