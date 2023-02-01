class Form::Lettings::Questions::Age5Known < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "age5_known"
    @check_answer_label = ""
    @header = "Do you know person 5’s age?"
    @type = "radio"
    @check_answers_card_number = 5
    @hint_text = ""
    @answer_options = ANSWER_OPTIONS
    @conditional_for = { "age5" => [0] }
    @hidden_in_check_answers = { "depends_on" => [{ "age5_known" => 0 }, { "age5_known" => 1 }] }
  end

  ANSWER_OPTIONS = { "0" => { "value" => "Yes" }, "1" => { "value" => "No" } }.freeze
end
