class Form::Lettings::Pages::Pregnant < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "pregnant"
    @header = ""
    @description = ""
  end

  def questions
    @questions ||= [Form::Lettings::Questions::PregOcc.new(nil, nil, self)]
  end
end
