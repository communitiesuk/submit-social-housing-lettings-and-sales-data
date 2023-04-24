class Form::Lettings::Questions::PregnancyValueCheck < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "pregnancy_value_check"
    @check_answer_label = "Pregnancy confirmation"
    @header = "Are you sure this is correct?"
    @type = "interruption_screen"
    @check_answers_card_number = 0
    @answer_options = ANSWER_OPTIONS
    @hidden_in_check_answers = { "depends_on" => [{ "pregnancy_value_check" => 0 }, { "pregnancy_value_check" => 1 }] }
  end

  ANSWER_OPTIONS = { "0" => { "value" => "Yes" }, "1" => { "value" => "No" } }.freeze

  def affected_question_ids
    %w[preg_occ sex1 sex2 sex3 sex4 sex5 sex6 sex7 sex8]
  end
end
