class Form::Sales::Pages::Equity < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @copy_key = "sales.sale_information.equity"
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Equity.new(nil, nil, self),
    ]
  end
end
