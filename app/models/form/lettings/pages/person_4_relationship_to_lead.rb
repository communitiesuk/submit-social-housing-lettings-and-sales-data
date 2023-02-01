class Form::Lettings::Pages::Person4RelationshipToLead < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "person_4_relationship_to_lead"
    @header = ""
    @depends_on = [{ "details_known_4" => 0 }]
    @description = ""
  end

  def questions
    @questions ||= [Form::Lettings::Questions::Relat4.new(nil, nil, self)]
  end
end
