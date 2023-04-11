class Form::Lettings::Questions::PreviousLaKnown < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "previous_la_known"
    @check_answer_label = "Do you know the local authority of the household’s last settled accommodation?"
    @header = "Do you know the local authority of the household’s last settled accommodation?"
    @type = "radio"
    @check_answers_card_number = 0
    @hint_text = "This is also known as the household’s ‘last settled home’."
    @answer_options = ANSWER_OPTIONS
    @conditional_for = { "prevloc" => [1] }
    @hidden_in_check_answers = { "depends_on" => [{ "previous_la_known" => 0 }, { "previous_la_known" => 1 }] }
    @question_number = 81
    @do_not_clear = true
  end

  ANSWER_OPTIONS = { "1" => { "value" => "Yes" }, "0" => { "value" => "No" } }.freeze
end
