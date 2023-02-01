class Form::Lettings::Questions::Sex3 < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "sex3"
    @check_answer_label = "Person 3’s gender identity"
    @header = "Which of these best describes person 3’s gender identity?"
    @type = "radio"
    @check_answers_card_number = 3
    @hint_text = ""
    @answer_options = ANSWER_OPTIONS
  end

  ANSWER_OPTIONS = { "F" => { "value" => "Female" }, "M" => { "value" => "Male" }, "X" => { "value" => "Non-binary" }, "divider" => { "value" => true }, "R" => { "value" => "Person prefers not to say" } }.freeze
end
