class Form::Lettings::Pages::Person7Known < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "person_7_known"
    @header = "You’ve given us the details for 6 people in the household"
    @depends_on = [{ "hhmemb" => 7 }, { "hhmemb" => 8 }]
    @description = ""
  end

  def questions
    @questions ||= [Form::Lettings::Questions::DetailsKnown7.new(nil, nil, self)]
  end
end
