class Form::Lettings::Pages::Person6RelationshipToLead < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "person_6_relationship_to_lead"
    @header = ""
    @depends_on = [{ "details_known_6" => 0 }]
    @description = ""
  end

  def questions
    @questions ||= [Form::Lettings::Questions::Relat6.new(nil, nil, self)]
  end
end
