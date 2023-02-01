class Form::Lettings::Pages::Person8Age < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "person_8_age"
    @header = ""
    @depends_on = [{ "details_known_8" => 0 }]
    @description = ""
  end

  def questions
    @questions ||= [Form::Lettings::Questions::Age8Known.new(nil, nil, self), Form::Lettings::Questions::Age8.new(nil, nil, self)]
  end
end
