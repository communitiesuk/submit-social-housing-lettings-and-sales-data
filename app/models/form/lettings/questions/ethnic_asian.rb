class Form::Lettings::Questions::EthnicAsian < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "ethnic"
    @check_answer_label = "Lead tenant’s ethnic background"
    @header = "Which of the following best describes the lead tenant’s Asian or Asian British background?"
    @type = "radio"
    @check_answers_card_number = 1
    @hint_text = "The lead tenant is the person in the household who does the most paid work. If several people do the same paid work, the lead tenant is whoever is the oldest."
    @answer_options = ANSWER_OPTIONS
    @question_number = QUESION_NUMBER_FROM_YEAR.fetch(form.start_date.year, QUESION_NUMBER_FROM_YEAR.max_by { |k, _v| k }.last)
  end

  ANSWER_OPTIONS = {
    "10" => {
      "value" => "Bangladeshi",
    },
    "15" => {
      "value" => "Chinese",
    },
    "8" => {
      "value" => "Indian",
    },
    "9" => {
      "value" => "Pakistani",
    },
    "11" => {
      "value" => "Any other Asian or Asian British background",
    },
  }.freeze

  QUESION_NUMBER_FROM_YEAR = { 2023 => 35, 2024 => 34 }.freeze
end
