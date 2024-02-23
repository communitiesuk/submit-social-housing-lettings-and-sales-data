class Form::Sales::Questions::Buyer1EthnicBackgroundAsian < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "ethnic"
    @check_answer_label = "Buyer 1’s ethnic background"
    @header = "Which of the following best describes buyer 1’s Asian or Asian British background?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @hint_text = "Buyer 1 is the person in the household who does the most paid work. If it’s a joint purchase and the buyers do the same amount of paid work, buyer 1 is whoever is the oldest."
    @check_answers_card_number = 1
    @question_number = QUESTION_NUMBER_FROM_YEAR.fetch(form.start_date.year, QUESTION_NUMBER_FROM_YEAR.max_by { |k, _v| k }.last)
  end

  ANSWER_OPTIONS = {
    "10" => { "value" => "Bangladeshi" },
    "15" => { "value" => "Chinese" },
    "8" => { "value" => "Indian" },
    "9" => { "value" => "Pakistani" },
    "11" => { "value" => "Any other Asian or Asian British background" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 23, 2024 => 25 }.freeze
end
