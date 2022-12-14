class Form::Sales::Pages::Person1GenderIdentity < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "person_1_gender_identity"
    @header = ""
    @description = ""
    @subsection = subsection
    @depends_on = [
      { "details_known_1" => 1, "jointpur" => 2 },
    ]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Person1GenderIdentity.new("sex2", nil, self),
    ]
  end
end
