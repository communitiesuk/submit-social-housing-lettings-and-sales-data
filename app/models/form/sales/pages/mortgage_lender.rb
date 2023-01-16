class Form::Sales::Pages::MortgageLender < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @header = ""
    @description = ""
    @subsection = subsection
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::MortgageLender.new(nil, nil, self),
    ]
  end
end
