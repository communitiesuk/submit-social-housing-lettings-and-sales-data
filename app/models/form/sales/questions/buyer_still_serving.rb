class Form::Sales::Questions::BuyerStillServing < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "hhregresstill"
    @check_answer_label = "Are they still serving in the UK armed forces?"
    @header = "Q63 - Is the buyer still serving in the UK armed forces?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
  end

  ANSWER_OPTIONS = {
    "4" => { "value" => "Yes" },
    "5" => { "value" => "No" },
    "6" => { "value" => "Buyer prefers not to say" },
    "7" => { "value" => "Don't know" },
  }.freeze
end
