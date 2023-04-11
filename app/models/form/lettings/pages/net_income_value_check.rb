class Form::Lettings::Pages::NetIncomeValueCheck < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "net_income_value_check"
    @depends_on = [{ "net_income_soft_validation_triggered?" => true }]
    @title_text = { "translation" => "soft_validations.net_income.title_text" }
    @informative_text = {
      "translation" => "soft_validations.net_income.hint_text",
      "arguments" => [
        {
          "key" => "field_formatted_as_currency",
          "arguments_for_key" => "ecstat1",
          "i18n_template" => "ecstat1",
        },
        {
          "key" => "field_formatted_as_currency",
          "arguments_for_key" => "earnings",
          "i18n_template" => "earnings",
        },
      ],
    }
  end

  def questions
    @questions ||= [Form::Lettings::Questions::NetIncomeValueCheck.new(nil, nil, self)]
  end
end
