class Form::Lettings::Pages::Person3GenderIdentity < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "person_3_gender_identity"
    @header = ""
    @depends_on = [{ "details_known_3" => 0 }]
    @description = ""
  end

  def questions
    @questions ||= [Form::Lettings::Questions::Sex3.new(nil, nil, self)]
  end
end
