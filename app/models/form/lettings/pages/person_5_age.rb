class Form::Lettings::Pages::Person5Age < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "person_5_age"
    @header = ""
    @depends_on = [{ "details_known_5" => 0 }]
    @description = ""
  end

  def questions
    @questions ||= [Form::Lettings::Questions::Age5Known.new(nil, nil, self), Form::Lettings::Questions::Age5.new(nil, nil, self)]
  end
end
