class Form::Lettings::Questions::Age6Known < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "age6_known"
    @check_answer_label = ""
    @header = "Do you know person 6’s age?"
    @type = "radio"
    @check_answers_card_number = 6
    @hint_text = ""
    @answer_options = ANSWER_OPTIONS
    @conditional_for = { "age6" => [0] }
    @hidden_in_check_answers = { "depends_on" => [{ "age6_known" => 0 }, { "age6_known" => 1 }] }
  end

  ANSWER_OPTIONS = { "0" => { "value" => "Yes" }, "1" => { "value" => "No" } }.freeze
end
