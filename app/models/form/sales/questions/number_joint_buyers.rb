class Form::Sales::Questions::NumberJointBuyers < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "jointmore"
    @check_answer_label = "More than 2 joint buyers"
    @header = "Q10 - Are there more than 2 joint buyers of this property?"
    @hint_text = "You should still try to answer all questions even if the buyer wasn't interviewed in person"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "2" => { "value" => "No" },
    "3" => { "value" => "Don’t know" },
  }.freeze
end
