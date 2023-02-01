class Form::Lettings::Pages::PersonRelationshipToLead < ::Form::Page
  def initialize(id, hsh, subsection, person_index:)
    super(id, hsh, subsection)
    @id = "person_#{person_index}_relationship_to_lead"
    @header = ""
    @depends_on = [{ "details_known_#{person_index}" => 0 }]
    @description = ""
    @person_index = person_index
  end

  def questions
    @questions ||= [Form::Lettings::Questions::PersonRelationship.new(nil, nil, self, person_index: @person_index)]
  end
end
