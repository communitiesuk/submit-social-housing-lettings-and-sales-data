class Form::Sales::Pages::Person4Known < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "person_4_known"
    @header_partial = "person_4_known_page"
    @header = ""
    @description = ""
    @subsection = subsection
    @depends_on = [
      { "hholdcount" => 4, "jointpur" => 2 },
    ]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Person4Known.new(nil, { check_answers_card_number: 5 }, self),
    ]
  end
end
