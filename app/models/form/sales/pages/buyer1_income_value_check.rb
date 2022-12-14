class Form::Sales::Pages::Buyer1IncomeValueCheck < ::Form::Page
  def initialize(id, hsh, subsection, dynamic_values = {})
    super
    @id = "#{dynamic_values.present? ? dynamic_values[:id_prefix] : ''}buyer_1_income_value_check"
    @header = ""
    @description = ""
    @subsection = subsection
    @depends_on = [
      {
        "income1_under_soft_min?" => true,
      },
    ]
    @informative_text = {}
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Buyer1IncomeValueCheck.new(nil, nil, self),
    ]
  end
end
