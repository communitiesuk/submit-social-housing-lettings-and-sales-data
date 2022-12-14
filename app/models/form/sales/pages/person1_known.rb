class Form::Sales::Pages::Person1Known < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "person_1_known"
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
      Form::Sales::Questions::Person1Known.new(nil, { check_answers_card_number: 2 }, self),
    ]
  end
end
