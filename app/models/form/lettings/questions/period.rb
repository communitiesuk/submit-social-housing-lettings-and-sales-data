class Form::Lettings::Questions::Period < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "period"
    @check_answer_label = "Frequency of household rent and charges"
    @header = "How often does the household pay rent and other charges?"
    @type = "radio"
    @check_answers_card_number = 0
    @hint_text = "Select how often the household is charged. This may be different to how often they pay."
    @answer_options = ANSWER_OPTIONS
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  ANSWER_OPTIONS = {
    "2" => { "value" => "Every 2 weeks" },
    "3" => { "value" => "Every 4 weeks" },
    "4" => { "value" => "Every calendar month" },
    "9" => { "value" => "Weekly for 46 weeks" },
    "8" => { "value" => "Weekly for 47 weeks" },
    "7" => { "value" => "Weekly for 48 weeks" },
    "6" => { "value" => "Weekly for 49 weeks" },
    "5" => { "value" => "Weekly for 50 weeks" },
    "1" => { "value" => "Weekly for 52 weeks" },
    "10" => { "value" => "Weekly for 53 weeks" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 92, 2024 => 91 }.freeze
end
