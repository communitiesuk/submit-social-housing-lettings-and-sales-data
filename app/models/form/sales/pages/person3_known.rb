class Form::Sales::Pages::Person3Known < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "person_3_known"
    @header_partial = "person_3_known_page"
    @header = ""
    @description = ""
    @subsection = subsection
    @depends_on = [
      { "hholdcount" => 3, "details_known_2" => 1 },
      { "hholdcount" => 4, "details_known_2" => 1 },
    ]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Person3Known.new(nil, nil, self),
    ]
  end
end
