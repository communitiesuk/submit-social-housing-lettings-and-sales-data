class Form::Sales::Pages::LocalAuthority < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "la"
    @header = ""
    @description = ""
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::LocalAuthority.new(nil, nil, self),
    ]
  end
end
