class Form::Sales::Questions::JointPurchase < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "type"
    @check_answer_label = "Joint purchase"
    @header = "Is this a joint purchase?"
    @hint_text = ""
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @page = page
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "0" => { "value" => "No" },
  }.freeze
end
