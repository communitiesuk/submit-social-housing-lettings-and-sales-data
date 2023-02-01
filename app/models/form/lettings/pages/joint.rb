class Form::Lettings::Pages::Joint < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "joint"
    @header = ""
    @description = ""
  end

  def questions
    @questions ||= [Form::Lettings::Questions::Joint.new(nil, nil, self)]
  end
end
