class Form::Lettings::Questions::Age4Known < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "age4_known"
    @check_answer_label = ""
    @header = "Do you know person 4’s age?"
    @type = "radio"
    @check_answers_card_number = 4
    @hint_text = ""
    @answer_options = ANSWER_OPTIONS
    @conditional_for = { "age4" => [0] }
    @hidden_in_check_answers = { "depends_on" => [{ "age4_known" => 0 }, { "age4_known" => 1 }] }
  end

  ANSWER_OPTIONS = { "0" => { "value" => "Yes" }, "1" => { "value" => "No" } }.freeze
end
