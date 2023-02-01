class Form::Lettings::Pages::Person4GenderIdentity < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "person_4_gender_identity"
    @header = ""
    @depends_on = [{ "details_known_4" => 0 }]
    @description = ""
  end

  def questions
    @questions ||= [Form::Lettings::Questions::Sex4.new(nil, nil, self)]
  end
end
