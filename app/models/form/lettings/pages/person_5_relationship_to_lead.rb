class Form::Lettings::Pages::Person5RelationshipToLead < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "person_5_relationship_to_lead"
    @header = ""
    @depends_on = [{ "details_known_5" => 0 }]
    @description = ""
  end

  def questions
    @questions ||= [Form::Lettings::Questions::Relat5.new(nil, nil, self)]
  end
end
