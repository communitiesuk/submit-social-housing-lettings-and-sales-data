class Form::Sales::Pages::Person1RelationshipToBuyer1 < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "person_1_relationship_to_buyer_1"
    @header = ""
    @description = ""
    @subsection = subsection
    @depends_on = [
      { "hholdcount" => 1 },
      { "hholdcount" => 2 },
      { "hholdcount" => 3 },
      { "hholdcount" => 4 },
    ]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Person1RelationshipToBuyer1.new(nil, nil, self),
    ]
  end
end
