class Form::Lettings::Pages::Person7Age < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "person_7_age"
    @header = ""
    @depends_on = [{ "details_known_7" => 0 }]
    @description = ""
  end

  def questions
    @questions ||= [Form::Lettings::Questions::Age7Known.new(nil, nil, self), Form::Lettings::Questions::Age7.new(nil, nil, self)]
  end
end
