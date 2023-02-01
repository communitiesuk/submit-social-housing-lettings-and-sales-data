class Form::Lettings::Pages::IncomeKnown < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "income_known"
    @header = "Household’s combined income after tax"
    @description = ""
  end

  def questions
    @questions ||= [Form::Lettings::Questions::NetIncomeKnown.new(nil, nil, self)]
  end
end
