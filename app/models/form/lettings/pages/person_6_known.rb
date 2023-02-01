class Form::Lettings::Pages::Person6Known < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "person_6_known"
    @header = "You’ve given us the details for 5 people in the household"
    @depends_on = [{ "hhmemb" => 6 }, { "hhmemb" => 7 }, { "hhmemb" => 8 }]
    @description = ""
  end

  def questions
    @questions ||= [Form::Lettings::Questions::DetailsKnown6.new(nil, nil, self)]
  end
end
