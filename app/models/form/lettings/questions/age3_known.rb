class Form::Lettings::Questions::Age3Known < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "age3_known"
    @check_answer_label = ""
    @header = "Do you know person 3’s age?"
    @type = "radio"
    @check_answers_card_number = 3
    @hint_text = ""
    @answer_options = ANSWER_OPTIONS
    @conditional_for = { "age3" => [0] }
    @hidden_in_check_answers = { "depends_on" => [{ "age3_known" => 0 }, { "age3_known" => 1 }] }
  end

  ANSWER_OPTIONS = { "0" => { "value" => "Yes" }, "1" => { "value" => "No" } }.freeze
end
