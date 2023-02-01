class Form::Lettings::Questions::Age2Known < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "age2_known"
    @check_answer_label = ""
    @header = "Do you know person 2’s age?"
    @type = "radio"
    @check_answers_card_number = 2
    @hint_text = ""
    @answer_options = ANSWER_OPTIONS
    @conditional_for = { "age2" => [0] }
    @hidden_in_check_answers = { "depends_on" => [{ "age2_known" => 0 }, { "age2_known" => 1 }] }
  end

  ANSWER_OPTIONS = { "0" => { "value" => "Yes" }, "1" => { "value" => "No" } }.freeze
end
