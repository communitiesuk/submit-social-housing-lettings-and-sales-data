class Form::Sales::Pages::Staircase < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "staircasing"
    @header = ""
    @description = ""
    @subsection = subsection
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Staircase.new(nil, nil, self),
    ]
  end
end
