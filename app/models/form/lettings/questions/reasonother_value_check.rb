class Form::Lettings::Questions::ReasonotherValueCheck < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "reasonother_value_check"
    @check_answer_label = "Reason other confirmation"
    @header = "Are you sure this doesn’t fit an existing category?"
    @type = "interruption_screen"
    @check_answers_card_number = 0
    @answer_options = ANSWER_OPTIONS
    @hidden_in_check_answers = { "depends_on" => [{ "reasonother_value_check" => 0 }, { "reasonother_value_check" => 1 }] }
  end

  ANSWER_OPTIONS = { "0" => { "value" => "Yes" }, "1" => { "value" => "No" } }.freeze
end
