class Form::Lettings::Questions::NetIncomeValueCheck < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "net_income_value_check"
    @check_answer_label = "Net income confirmation"
    @header = "Are you sure this is correct?"
    @type = "interruption_screen"
    @check_answers_card_number = 0
    @answer_options = ANSWER_OPTIONS
    @hidden_in_check_answers = {
      "depends_on" => [
        { "net_income_value_check" => 0 },
        { "net_income_value_check" => 1 },
      ],
    }
  end

  ANSWER_OPTIONS = { "0" => { "value" => "Yes" }, "1" => { "value" => "No" } }.freeze
end
