class Form::Sales::Questions::Buyer1EthnicBackgroundMixed < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "ethnic"
    @check_answer_label = "Buyer 1’s ethnic background"
    @header = "Which of the following best describes buyer 1’s Mixed or Multiple ethnic groups background?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @hint_text = form.start_year_after_2024? ? "" : "Buyer 1 is the person in the household who does the most paid work. If it’s a joint purchase and the buyers do the same amount of paid work, buyer 1 is whoever is the oldest."
    @check_answers_card_number = 1
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  ANSWER_OPTIONS = {
    "4" => { "value" => "White and Black Caribbean" },
    "5" => { "value" => "White and Black African" },
    "6" => { "value" => "White and Asian" },
    "7" => { "value" => "Any other Mixed or Multiple ethnic background" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 23, 2024 => 25 }.freeze
end
