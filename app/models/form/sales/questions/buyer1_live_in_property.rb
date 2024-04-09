class Form::Sales::Questions::Buyer1LiveInProperty < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "buy1livein"
    @check_answer_label = "Will buyer 1 live in the property?"
    @header = "Will buyer 1 live in the property?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @hint_text = form.start_year_after_2024? ? "" : "Buyer 1 is the person in the household who does the most paid work. If it’s a joint purchase and the buyers do the same amount of paid work, buyer 1 is whoever is the oldest."
    @check_answers_card_number = 1
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "2" => { "value" => "No" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 26, 2024 => 28 }.freeze
end
