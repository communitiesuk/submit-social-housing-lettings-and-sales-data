class Form::Sales::Pages::Person1Known < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "person_1_known"
    @header_partial = "person_1_known_page"
    @header = ""
    @description = ""
    @subsection = subsection
    @depends_on = [
      { "hholdcount" => 1 },
      { "hholdcount" => 2 },
      { "hholdcount" => 3 },
      { "hholdcount" => 4 },
    ]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Person1Known.new(nil, nil, self),
    ]
  end
end
