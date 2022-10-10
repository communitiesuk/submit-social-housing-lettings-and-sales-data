class Form::Sales::Pages::PersonXKnown < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = person_x_known_id
    @header_partial = "person_x_known_page"
    @header = ""
    @description = ""
    @subsection = subsection
    @depends_on = [
      { "hholdcount" => 2 },
      { "hholdcount" => 3 },
      { "hholdcount" => 4 },
    ]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::PersonXKnown.new(nil, nil, self),
    ]
  end
end
