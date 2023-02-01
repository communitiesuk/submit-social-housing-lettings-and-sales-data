class Form::Lettings::Pages::Person7GenderIdentity < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "person_7_gender_identity"
    @header = ""
    @depends_on = [{ "details_known_7" => 0 }]
    @description = ""
  end

  def questions
    @questions ||= [Form::Lettings::Questions::Sex7.new(nil, nil, self)]
  end
end
