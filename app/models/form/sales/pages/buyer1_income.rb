class Form::Sales::Pages::Buyer1Income < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "buyer_1_income"
    @header = ""
    @description = ""
    @subsection = subsection
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Buyer1IncomeKnown.new(nil, nil, self),
      Form::Sales::Questions::Buyer1Income.new(nil, nil, self),
    ]
  end
end
