class Form::Lettings::Pages::Person8Known < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "person_8_known"
    @header = "You’ve given us the details for 7 people in the household"
    @depends_on = [{ "hhmemb" => 8 }]
    @description = ""
  end

  def questions
    @questions ||= [Form::Lettings::Questions::DetailsKnown8.new(nil, nil, self)]
  end
end
