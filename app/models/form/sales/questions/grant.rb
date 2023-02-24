class Form::Sales::Questions::Grant < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "grant"
    @check_answer_label = "Amount of any loan, grant or subsidy"
    @header = "Q101 - What was the amount of any loan, grant, discount or subsidy given?"
    @type = "numeric"
    @min = 0
    @max = 999_999
    @width = 5
    @prefix = "£"
    @hint_text = "For all schemes except Right to Buy (RTB), Preserved Right to Buy (PRTB), Voluntary Right to Buy (VRTB)"
  end
end
