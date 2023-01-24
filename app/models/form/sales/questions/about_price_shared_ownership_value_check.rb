class Form::Sales::Questions::AboutPriceSharedOwnershipValueCheck < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "value_value_check"
    @check_answer_label = "Deposit confirmation"
    @header = "Are you sure? This purchase price is outside the expected range for this local authority and number of bedrooms"
    @type = "interruption_screen"
    @answer_options = {
      "0" => { "value" => "Yes" },
      "1" => { "value" => "No" },
    }
    @hidden_in_check_answers = {
      "depends_on" => [
        {
          "value_value_check" => 0,
        },
        {
          "value_value_check" => 1,
        },
      ],
    }
  end
end
