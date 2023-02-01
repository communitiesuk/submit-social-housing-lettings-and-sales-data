class Form::Lettings::Questions::Age7Known < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "age7_known"
    @check_answer_label = ""
    @header = "Do you know person 7’s age?"
    @type = "radio"
    @check_answers_card_number = 7
    @hint_text = ""
    @answer_options = ANSWER_OPTIONS
    @conditional_for = { "age7" => [0] }
    @hidden_in_check_answers = { "depends_on" => [{ "age7_known" => 0 }, { "age7_known" => 1 }] }
  end

  ANSWER_OPTIONS = { "0" => { "value" => "Yes" }, "1" => { "value" => "No" } }.freeze
end
