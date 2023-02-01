class Form::Lettings::Pages::Person2GenderIdentity < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "person_2_gender_identity"
    @header = ""
    @depends_on = [{ "details_known_2" => 0 }]
    @description = ""
  end

  def questions
    @questions ||= [Form::Lettings::Questions::Sex2.new(nil, nil, self)]
  end
end
