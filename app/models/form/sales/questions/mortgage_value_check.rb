class Form::Sales::Questions::MortgageValueCheck < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "mortgage_value_check"
    @check_answer_label = "Mortgage confirmation"
    @header = "Are you sure that the mortgage is more than 5 times the income used for the mortgage application?"
    @type = "interruption_screen"
    @answer_options = {
      "0" => { "value" => "Yes" },
      "1" => { "value" => "No" },
    }
    @hidden_in_check_answers = {
      "depends_on" => [
        {
          "mortgage_value_check" => 0,
        },
        {
          "mortgage_value_check" => 1,
        },
      ],
    }
    @check_answers_card_number = 1
  end
end
