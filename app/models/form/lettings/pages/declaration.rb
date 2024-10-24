class Form::Lettings::Pages::Declaration < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "declaration"
  end

  def questions
    @questions ||= [Form::Lettings::Questions::Declaration.new(nil, nil, self)]
  end
end
