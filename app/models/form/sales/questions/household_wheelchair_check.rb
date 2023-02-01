class Form::Sales::Questions::HouseholdWheelchairCheck < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "wheel_value_check"
    @check_answer_label = "Does anyone in the household use a wheelchair?"
    @header = "Are you sure? Earlier, you said that that nobody in the household considers themselves to have a disability"
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
