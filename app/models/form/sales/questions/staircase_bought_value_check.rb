class Form::Sales::Questions::StaircaseBoughtValueCheck < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "staircase_bought_value_check"
    @check_answer_label = "Percentage bought confirmation"
    @header = "Are you sure this is correct?"
    @type = "interruption_screen"
    @answer_options = {
      "0" => { "value" => "Yes" },
      "1" => { "value" => "No" },
    }
    @hidden_in_check_answers = {
      "depends_on" => [
        {
          "staircase_bought_value_check" => 0,
        },
        {
          "staircase_bought_value_check" => 1,
        },
      ],
    }
  end
end
