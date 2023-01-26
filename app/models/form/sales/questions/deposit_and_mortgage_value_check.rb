class Form::Sales::Questions::DepositAndMortgageValueCheck < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "deposit_and_mortgage_value_check"
    @check_answer_label = "Deposit and mortgage against discount confirmation" # is this meant to come from somewhere or do I just write something sensible?
    @header = "Are you sure? Mortgage and deposit usually equal or are more than (value - discount)"
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
