class Form::Lettings::Questions::NoRetirementValueCheck < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "retirement_value_check"
    @check_answer_label = "Retirement confirmation"
    @header = "Are you sure this person is retired?"
    @type = "interruption_screen"
    @check_answers_card_number = 8
    @answer_options = ANSWER_OPTIONS
    @hidden_in_check_answers = { "depends_on" => [{ "retirement_value_check" => 0 }, { "retirement_value_check" => 1 }] }
  end

  ANSWER_OPTIONS = { "0" => { "value" => "Yes" }, "1" => { "value" => "No" } }.freeze
end
