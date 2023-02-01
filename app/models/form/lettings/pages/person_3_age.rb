class Form::Lettings::Pages::Person3Age < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "person_3_age"
    @header = ""
    @depends_on = [{ "details_known_3" => 0 }]
    @description = ""
  end

  def questions
    @questions ||= [Form::Lettings::Questions::Age3Known.new(nil, nil, self), Form::Lettings::Questions::Age3.new(nil, nil, self)]
  end
end
