class Form::Lettings::Pages::Person4Known < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "person_4_known"
    @header = "You’ve given us the details for 3 people in the household"
    @depends_on = [{ "hhmemb" => 4 }, { "hhmemb" => 5 }, { "hhmemb" => 6 }, { "hhmemb" => 7 }, { "hhmemb" => 8 }]
    @description = ""
  end

  def questions
    @questions ||= [Form::Lettings::Questions::DetailsKnown4.new(nil, nil, self)]
  end
end
