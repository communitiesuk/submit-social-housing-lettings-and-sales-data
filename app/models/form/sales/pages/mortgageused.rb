class Form::Sales::Pages::Mortgageused < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @header = ""
    @subsection = subsection
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Mortgageused.new(nil, nil, self),
    ]
  end
end
