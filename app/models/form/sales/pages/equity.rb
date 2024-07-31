class Form::Sales::Pages::Equity < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "equity"
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Equity.new(nil, nil, self),
    ]
  end
end
