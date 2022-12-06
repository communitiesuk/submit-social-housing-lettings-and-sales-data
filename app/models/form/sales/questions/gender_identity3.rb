class Form::Sales::Questions::GenderIdentity3 < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "sex3"
    @check_answer_label = "Person 1’s gender identity"
    @header = "Which of these best describes Person 1’s gender identity?"
    @type = "radio"
    @page = page
    @answer_options = ANSWER_OPTIONS
    @check_answers_card_number = 3
  end

  ANSWER_OPTIONS = {
    "F" => { "value" => "Female" },
    "M" => { "value" => "Male" },
    "X" => { "value" => "Non-binary" },
    "R" => { "value" => "Buyer prefers not to say" },
  }.freeze
end
