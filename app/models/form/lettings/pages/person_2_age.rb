class Form::Lettings::Pages::Person2Age < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "person_2_age"
    @header = ""
    @depends_on = [{ "details_known_2" => 0 }]
    @description = ""
  end

  def questions
    @questions ||= [Form::Lettings::Questions::Age2Known.new(nil, nil, self), Form::Lettings::Questions::Age2.new(nil, nil, self)]
  end
end
