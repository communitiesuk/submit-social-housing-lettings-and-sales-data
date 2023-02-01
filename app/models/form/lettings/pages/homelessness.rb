class Form::Lettings::Pages::Homelessness < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "homelessness"
    @header = ""
    @description = ""
  end

  def questions
    @questions ||= [Form::Lettings::Questions::Homeless.new(nil, nil, self)]
  end
end
