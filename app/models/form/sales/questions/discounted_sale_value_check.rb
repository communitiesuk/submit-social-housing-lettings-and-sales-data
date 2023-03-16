class Form::Sales::Questions::DiscountedSaleValueCheck < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "discounted_sale_value_check"
    @check_answer_label = "Discounted sale value confirmation"
    @header = "Are you sure?"
    @type = "interruption_screen"
    @answer_options = {
      "0" => { "value" => "Yes" },
      "1" => { "value" => "No" },
    }
    @hidden_in_check_answers = {
      "depends_on" => [
        {
          "discounted_sale_value_check" => 0,
        },
        {
          "discounted_sale_value_check" => 1,
        },
      ],
    }
  end
end
