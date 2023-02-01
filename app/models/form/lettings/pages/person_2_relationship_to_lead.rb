class Form::Lettings::Pages::Person2RelationshipToLead < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "person_2_relationship_to_lead"
    @header = ""
    @depends_on = [{ "details_known_2" => 0 }]
    @description = ""
  end

  def questions
    @questions ||= [Form::Lettings::Questions::Relat2.new(nil, nil, self)]
  end
end
