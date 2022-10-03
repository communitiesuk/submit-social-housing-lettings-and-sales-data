class Form::Sales::Questions::GenderIdentity2 < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "sex2"
    @check_answer_label = "Buyer 2’s gender identity"
    @header = "Which of these best describes buyer 2’s gender identity?"
    @type = "radio"
    @page = page
    @answer_options = ANSWER_OPTIONS
  end

  ANSWER_OPTIONS = {
    "F" => { "value" => "Female" },
    "M" => { "value" => "Male" },
    "X" => { "value" => "Non-binary" },
    "R" => { "value" => "Buyer prefers not to say" },
  }.freeze
end
