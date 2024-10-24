class Form::Sales::Questions::HouseholdWheelchairCheck < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "wheel_value_check"
    @copy_key = "sales.soft_validations.wheel_value_check"
    @type = "interruption_screen"
    @answer_options = {
      "0" => { "value" => "Yes" },
      "1" => { "value" => "No" },
    }
    @hidden_in_check_answers = {
      "depends_on" => [
        {
          "wheel_value_check" => 0,
        },
        {
          "wheel_value_check" => 1,
        },
      ],
    }
    @page = page
  end
end
