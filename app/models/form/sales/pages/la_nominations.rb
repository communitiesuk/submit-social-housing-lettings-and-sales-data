class Form::Sales::Pages::LaNominations < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "la_nominations"
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::LaNominations.new(nil, nil, self),
    ]
  end
end
