class Form::Lettings::Questions::Age8Known < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "age8_known"
    @check_answer_label = ""
    @header = "Do you know person 8’s age?"
    @type = "radio"
    @check_answers_card_number = 8
    @hint_text = ""
    @answer_options = ANSWER_OPTIONS
    @conditional_for = { "age8" => [0] }
    @hidden_in_check_answers = { "depends_on" => [{ "age8_known" => 0 }, { "age8_known" => 1 }] }
  end

  ANSWER_OPTIONS = { "0" => { "value" => "Yes" }, "1" => { "value" => "No" } }.freeze
end
