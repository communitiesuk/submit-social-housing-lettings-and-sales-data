class Form::Sales::Pages::MortgageAmount < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @header = "Mortgage Amount"
    @description = ""
    @subsection = subsection
    @depends_on = [{
      "mortgageused" => 1,
    }]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::MortgageAmount.new(nil, nil, self),
    ]
  end
end
