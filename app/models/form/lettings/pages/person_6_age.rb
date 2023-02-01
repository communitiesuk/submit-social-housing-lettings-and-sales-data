class Form::Lettings::Pages::Person6Age < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "person_6_age"
    @header = ""
    @depends_on = [{ "details_known_6" => 0 }]
    @description = ""
  end

  def questions
    @questions ||= [Form::Lettings::Questions::Age6Known.new(nil, nil, self), Form::Lettings::Questions::Age6.new(nil, nil, self)]
  end
end
