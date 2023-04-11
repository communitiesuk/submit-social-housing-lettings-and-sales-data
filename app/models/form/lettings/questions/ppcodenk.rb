class Form::Lettings::Questions::Ppcodenk < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "ppcodenk"
    @check_answer_label = ""
    @header = "Do you know the postcode of the household’s last settled accommodation?"
    @type = "radio"
    @check_answers_card_number = 0
    @hint_text = "This is also known as the household’s ‘last settled home’."
    @answer_options = ANSWER_OPTIONS
    @conditional_for = { "ppostcode_full" => [1] }
    @hidden_in_check_answers = { "depends_on" => [{ "ppcodenk" => 0 }, { "ppcodenk" => 1 }] }
    @question_number = 80
    @do_not_clear = true
  end

  ANSWER_OPTIONS = { "1" => { "value" => "Yes" }, "0" => { "value" => "No" } }.freeze
end
