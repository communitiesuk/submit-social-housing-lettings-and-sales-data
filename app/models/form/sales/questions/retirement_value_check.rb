class Form::Sales::Questions::RetirementValueCheck < ::Form::Question
  def initialize(id, hsh, page, person_index:)
    super(id, hsh, page)
    @id = "retirement_value_check"
    @check_answer_label = "Retirement confirmation"
    @type = "interruption_screen"
    @answer_options = {
      "0" => { "value" => "Yes" },
      "1" => { "value" => "No" },
    }
    @hidden_in_check_answers = {
      "depends_on" => [
        {
          "retirement_value_check" => 0,
        },
        {
          "retirement_value_check" => 1,
        },
      ],
    }
    @check_answers_card_number = person_index
    @header = "Are you sure this person is retired?"
  end
end
