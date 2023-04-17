class Form::Sales::Pages::PercentageDiscountValueCheck < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @title_text = {
      "translation" => "soft_validations.percentage_discount_value.title_text",
      "arguments" => [{ "key" => "discount", "label" => true, "i18n_template" => "discount" }],
    }
    @informative_text = {}
    @depends_on = [{ "percentage_discount_invalid?" => true }]
  end

  def questions
    @questions ||= [Form::Sales::Questions::PercentageDiscountValueCheck.new(nil, nil, self)]
  end
end
