class Form::Sales::Pages::MortgageLength < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @header = ""
    @description = ""
    @subsection = subsection
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::MortgageLength.new(nil, nil, self),
    ]
  end
end
