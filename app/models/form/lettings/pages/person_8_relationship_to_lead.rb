class Form::Lettings::Pages::Person8RelationshipToLead < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "person_8_relationship_to_lead"
    @header = ""
    @depends_on = [{ "details_known_8" => 0 }]
    @description = ""
  end

  def questions
    @questions ||= [Form::Lettings::Questions::Relat8.new(nil, nil, self)]
  end
end
