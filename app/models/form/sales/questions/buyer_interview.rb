class Form::Sales::Questions::BuyerInterview < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "noint"
    @check_answer_label = "Buyer interviewed in person?"
    @header = "Was the buyer interviewed for any of the answers you will provide on this log?"
    @type = "radio"
    @hint_text = "You should still try to answer all questions even if the buyer wasn't interviewed in person"
    @page = page
    @answer_options = ANSWER_OPTIONS
  end

  ANSWER_OPTIONS = {
    "2" => { "value" => "Yes" },
    "1" => { "value" => "No" },
  }.freeze
end
