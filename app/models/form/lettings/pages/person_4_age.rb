class Form::Lettings::Pages::Person4Age < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "person_4_age"
    @header = ""
    @depends_on = [{ "details_known_4" => 0 }]
    @description = ""
  end

  def questions
    @questions ||= [Form::Lettings::Questions::Age4Known.new(nil, nil, self), Form::Lettings::Questions::Age4.new(nil, nil, self)]
  end
end
