class Form::Sales::Questions::DiscountedSaleValueCheck < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "discounted_sale_value_check"
    @copy_key = "sales.soft_validations.discounted_sale_value_check"
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
