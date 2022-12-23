class Form::Sales::Questions::HouseholdWheelchairCheck < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "wheel_value_check"
    @check_answer_label = "Does anyone in the household use a wheelchair?"
    @header = "Are you sure? You said previously that somebody in household uses a wheelchair"
    @type = "interruption_screen"
    @page = page
    @answer_options = {
      "0" => { "value" => "Yes" },
      "1" => { "value" => "No" },
    }
    @hidden_in_check_answers = true
    @page = page
  end
end
