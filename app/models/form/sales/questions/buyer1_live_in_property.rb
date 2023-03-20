class Form::Sales::Questions::Buyer1LiveInProperty < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "buy1livein"
    @check_answer_label = "Will buyer 1 live in the property?"
    @header = "Will buyer 1 live in the property?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @hint_text = "Buyer 1 is the person in the household who does the most paid work. If it’s a joint purchase and the buyers do the same amount of paid work, buyer 1 is whoever is the oldest."
    @check_answers_card_number = 1
    @question_number = 26
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "2" => { "value" => "No" },
  }.freeze
end
