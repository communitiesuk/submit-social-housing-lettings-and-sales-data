class Form::Sales::Pages::Person2Known < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "person_2_known"
    @header_partial = "personx_known_page"
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
      Form::Sales::Questions::Person2Known.new(nil, nil, self),
    ]
  end
end
