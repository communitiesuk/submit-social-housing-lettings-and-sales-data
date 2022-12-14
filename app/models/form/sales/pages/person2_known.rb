class Form::Sales::Pages::Person2Known < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "person_2_known"
    @header_partial = "person_2_known_page"
    @header = ""
    @description = ""
    @subsection = subsection
    @depends_on = [
      { "hholdcount" => 2, "jointpur" => 2 },
      { "hholdcount" => 3, "jointpur" => 2 },
      { "hholdcount" => 4, "jointpur" => 2 },
    ]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Person2Known.new(nil, { check_answers_card_number: 3 }, self),
    ]
  end
end
