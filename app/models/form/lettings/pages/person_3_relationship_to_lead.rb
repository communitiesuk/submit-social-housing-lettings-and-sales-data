class Form::Lettings::Pages::Person3RelationshipToLead < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "person_3_relationship_to_lead"
    @header = ""
    @depends_on = [{ "details_known_3" => 0 }]
    @description = ""
  end

  def questions
    @questions ||= [Form::Lettings::Questions::Relat3.new(nil, nil, self)]
  end
end
