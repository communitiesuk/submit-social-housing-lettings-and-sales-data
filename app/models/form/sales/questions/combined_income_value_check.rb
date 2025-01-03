class Form::Sales::Questions::CombinedIncomeValueCheck < ::Form::Question
  def initialize(id, hsh, page, check_answers_card_number:)
    super(id, hsh, page)
    @id = "combined_income_value_check"
    @copy_key = "sales.soft_validations.combined_income_value_check"
    @type = "interruption_screen"
    @answer_options = {
      "0" => { "value" => "Yes" },
      "1" => { "value" => "No" },
    }
    @hidden_in_check_answers = {
      "depends_on" => [
        {
          "combined_income_value_check" => 0,
        },
        {
          "combined_income_value_check" => 1,
        },
      ],
    }
    @check_answers_card_number = check_answers_card_number
    @page = page
  end
end
