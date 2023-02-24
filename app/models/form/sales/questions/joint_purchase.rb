class Form::Sales::Questions::JointPurchase < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "jointpur"
    @check_answer_label = "Joint purchase"
    @header = "Q9 - Is this a joint purchase?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "2" => { "value" => "No" },
  }.freeze
end
