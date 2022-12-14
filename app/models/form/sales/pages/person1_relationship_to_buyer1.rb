class Form::Sales::Pages::Person1RelationshipToBuyer1 < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "person_1_relationship_to_buyer_1"
    @header = ""
    @description = ""
    @subsection = subsection
    @depends_on = [
      { "details_known_1" => 1, "jointpur" => 2 },
    ]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Person1RelationshipToBuyer1.new("relat2", nil, self),
    ]
  end
end
