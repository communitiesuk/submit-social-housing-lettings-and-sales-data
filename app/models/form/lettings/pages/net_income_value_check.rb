class Form::Lettings::Pages::NetIncomeValueCheck < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "net_income_value_check"
    @depends_on = [{ "net_income_soft_validation_triggered?" => true }]
    @title_text = { "translation" => "soft_validations.net_income.title_text" }
    @informative_text = {
      "translation" => "soft_validations.net_income.hint_text",
      "arguments" => [
        { "key" => "ecstat1", "label" => true, "i18n_template" => "ecstat1", "money" => true },
        { "key" => "earnings", "label" => true, "i18n_template" => "earnings", "money" => true },
      ],
    }
  end

  def questions
    @questions ||= [Form::Lettings::Questions::NetIncomeValueCheck.new(nil, nil, self)]
  end
end
