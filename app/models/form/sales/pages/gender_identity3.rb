class Form::Sales::Pages::GenderIdentity3 < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "person_1_gender_identity"
    @header = ""
    @description = ""
    @subsection = subsection
    @depends_on = [{
      "jointpur" => 1,
    }]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::GenderIdentity3.new(nil, nil, self),
    ]
  end
end
