class Form::Lettings::Pages::Person8GenderIdentity < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "person_8_gender_identity"
    @header = ""
    @depends_on = [{ "details_known_8" => 0 }]
    @description = ""
  end

  def questions
    @questions ||= [Form::Lettings::Questions::Sex8.new(nil, nil, self)]
  end
end
