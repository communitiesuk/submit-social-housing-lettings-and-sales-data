class Form::Sales::Questions::Buyer2IncomeValueCheck < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "income2_value_check"
    @check_answer_label = "Income confirmation"
    @header = "Are you sure this income is correct?"
    @type = "interruption_screen"
    @answer_options = {
      "0" => { "value" => "Yes" },
      "1" => { "value" => "No" },
    }
    @hidden_in_check_answers = {
      "depends_on" => [
        {
          "income2_value_check" => 0,
        },
        {
          "income2_value_check" => 1,
        },
      ],
    }
    @check_answers_card_number = 2
    @page = page
  end
end
