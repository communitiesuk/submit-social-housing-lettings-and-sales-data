class Form::Sales::Questions::Buyer2LiveInProperty < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "buy2livein"
    @check_answer_label = "Will buyer 2 live in the property?"
    @header = "Will buyer 2 live in the property?"
    @type = "radio"
    @hint_text = ""
    @answer_options = ANSWER_OPTIONS
    @check_answers_card_number = 2
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "2" => { "value" => "No" },
  }.freeze
end
