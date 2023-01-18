class Form::Sales::Pages::MortgageValueCheck < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @depends_on = [
      {
        "mortgage_over_soft_max?" => true,
      },
    ]
    @informative_text = {}
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::MortgageValueCheck.new(nil, nil, self),
    ]
  end
end
