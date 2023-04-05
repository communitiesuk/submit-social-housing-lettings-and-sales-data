class Form::Sales::Questions::PercentageDiscountValueCheck < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "percentage_discount_value_check"
    @check_answer_label = "Percentage discount confirmation"
    @header = "Are you sure this is correct?"
    @type = "interruption_screen"
    @answer_options = {
      "0" => { "value" => "Yes" },
      "1" => { "value" => "No" },
    }
    @hidden_in_check_answers = {
      "depends_on" => [
        {
          "percentage_discount_value_check" => 0,
        },
        {
          "percentage_discount_value_check" => 1,
        },
      ],
    }
  end
end
