class Form::Sales::Questions::Buyer2LivingIn < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "buy2living"
    @check_answer_label = "All buyers living at the same address"
    @header = "Were all buyers living at the same address at the time of purchase?"
    @type = "radio"
    @hint_text = ""
    @answer_options = ANSWER_OPTIONS
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "2" => { "value" => "No" },
    "3" => { "value" => "Don't know" },
  }.freeze
end
