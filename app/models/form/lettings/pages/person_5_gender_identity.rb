class Form::Lettings::Pages::Person5GenderIdentity < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "person_5_gender_identity"
    @header = ""
    @depends_on = [{ "details_known_5" => 0 }]
    @description = ""
  end

  def questions
    @questions ||= [Form::Lettings::Questions::Sex5.new(nil, nil, self)]
  end
end
