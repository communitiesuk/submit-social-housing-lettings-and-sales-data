class Form::Sales::Questions::BuyerLive < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "buylivein"
    @check_answer_label = "Buyers living in property"
    @header = "Will the buyers live in the property?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @question_number = 8
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "2" => { "value" => "No" },
  }.freeze
end
