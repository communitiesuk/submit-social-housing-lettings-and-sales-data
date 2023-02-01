class Form::Lettings::Pages::Person7RelationshipToLead < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "person_7_relationship_to_lead"
    @header = ""
    @depends_on = [{ "details_known_7" => 0 }]
    @description = ""
  end

  def questions
    @questions ||= [Form::Lettings::Questions::Relat7.new(nil, nil, self)]
  end
end
