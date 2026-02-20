class Form::Sales::Questions::SavingsValueCheck < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "savings_value_check"
    @copy_key = "sales.soft_validations.savings_value_check"
    @type = "interruption_screen"
    @answer_options = {
      "0" => { "value" => "Yes" },
      "1" => { "value" => "No" },
    }
    @hidden_in_check_answers = {
      "depends_on" => [
        {
          "savings_value_check" => 0,
        },
        {
          "savings_value_check" => 1,
        },
      ],
    }
    @check_answers_card_number = 0 unless form.start_year_2026_or_later?
  end
end
