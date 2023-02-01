class Form::Lettings::Pages::Person5Known < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "person_5_known"
    @header = "You’ve given us the details for 4 people in the household"
    @depends_on = [{ "hhmemb" => 5 }, { "hhmemb" => 6 }, { "hhmemb" => 7 }, { "hhmemb" => 8 }]
    @description = ""
  end

  def questions
    @questions ||= [Form::Lettings::Questions::DetailsKnown5.new(nil, nil, self)]
  end
end
