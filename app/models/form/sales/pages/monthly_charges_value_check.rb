class Form::Sales::Pages::MonthlyChargesValueCheck < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @depends_on = [
      {
        "monthly_charges_over_soft_max?" => true,
      },
    ]
    @title_text = {
      "translation" => "soft_validations.monthly_charges_over_soft_max.title_text",
      "arguments" => [],
    }
    @informative_text = {}
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::MonthlyChargesValueCheck.new(nil, nil, self),
    ]
  end
end
