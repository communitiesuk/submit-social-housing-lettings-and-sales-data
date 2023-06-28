class Form::Sales::Questions::StaircaseOwnedValueCheck < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "stairowned_value_check"
    @check_answer_label = "Percentage owned confirmation"
    @header = "Are you sure?"
    @type = "interruption_screen"
    @answer_options = {
      "0" => { "value" => "Yes" },
      "1" => { "value" => "No" },
    }
    @hidden_in_check_answers = {
      "depends_on" => [
        {
          "stairowned_value_check" => 0,
        },
        {
          "stairowned_value_check" => 1,
        },
      ],
    }
  end
end
