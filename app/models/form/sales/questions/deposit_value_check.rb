class Form::Sales::Questions::DepositValueCheck < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "deposit_value_check"
    @check_answer_label = "Deposit confirmation"
    @header = "Are you sure that the deposit is this much higher than the buyer's savings?"
    @type = "interruption_screen"
    @answer_options = {
      "0" => { "value" => "Yes" },
      "1" => { "value" => "No" },
    }
    @hidden_in_check_answers = {
      "depends_on" => [
        {
          "deposit_value_check" => 0,
        },
        {
          "deposit_value_check" => 1,
        },
      ],
    }
    @check_answers_card_number = 0
    @page = page
  end
end
