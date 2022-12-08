class Form::Sales::Pages::Person1GenderIdentity < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "person_1_gender_identity"
    @header = ""
    @description = ""
    @subsection = subsection
    @depends_on = [
      { "hholdcount" => 1, "jointpur" => 2 },
      { "hholdcount" => 2, "jointpur" => 2 },
      { "hholdcount" => 3, "jointpur" => 2 },
      { "hholdcount" => 4, "jointpur" => 2 },
    ]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Person1GenderIdentity.new(nil, nil, self),
    ]
  end
end
