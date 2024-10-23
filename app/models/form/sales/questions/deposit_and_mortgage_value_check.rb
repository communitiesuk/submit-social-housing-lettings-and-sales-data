class Form::Sales::Questions::DepositAndMortgageValueCheck < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "deposit_and_mortgage_value_check"
    @copy_key = "sales.soft_validations.deposit_and_mortgage_value_check"
    @type = "interruption_screen"
    @answer_options = {
      "0" => { "value" => "Yes" },
      "1" => { "value" => "No" },
    }
    @hidden_in_check_answers = {
      "depends_on" => [
        {
          "deposit_and_mortgage_value_check" => 0,
        },
        {
          "deposit_and_mortgage_value_check" => 1,
        },
      ],
    }
  end
end
