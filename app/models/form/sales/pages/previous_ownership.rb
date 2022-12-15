class Form::Sales::Pages::PreviousOwnership < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "previous_ownership"
    @header = ""
    @description = ""
    @subsection = subsection
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Prevown.new(nil, nil, self),
    ]
  end
end
