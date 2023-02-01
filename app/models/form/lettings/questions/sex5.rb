class Form::Lettings::Questions::Sex5 < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "sex5"
    @check_answer_label = "Person 5’s gender identity"
    @header = "Which of these best describes person 5’s gender identity?"
    @type = "radio"
    @check_answers_card_number = 5
    @hint_text = ""
    @answer_options = ANSWER_OPTIONS
  end

  ANSWER_OPTIONS = { "F" => { "value" => "Female" }, "M" => { "value" => "Male" }, "X" => { "value" => "Non-binary" }, "divider" => { "value" => true }, "R" => { "value" => "Person prefers not to say" } }.freeze
end
