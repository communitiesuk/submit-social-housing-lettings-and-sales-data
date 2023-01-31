class Form::Sales::Questions::MonthlyChargesValueCheck < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "monthly_charges_value_check"
    @check_answer_label = "Monthly charges confirmation"
    @header = "Are you sure this is correct?"
    @type = "interruption_screen"
    @answer_options = {
      "0" => { "value" => "Yes" },
      "1" => { "value" => "No" },
    }
    @hidden_in_check_answers = {
      "depends_on" => [
        {
          "monthly_charges_value_check" => 0,
        },
        {
          "monthly_charges_value_check" => 1,
        },
      ],
    }
  end
end
