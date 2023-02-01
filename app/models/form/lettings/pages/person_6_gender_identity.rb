class Form::Lettings::Pages::Person6GenderIdentity < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "person_6_gender_identity"
    @header = ""
    @depends_on = [{ "details_known_6" => 0 }]
    @description = ""
  end

  def questions
    @questions ||= [Form::Lettings::Questions::Sex6.new(nil, nil, self)]
  end
end
