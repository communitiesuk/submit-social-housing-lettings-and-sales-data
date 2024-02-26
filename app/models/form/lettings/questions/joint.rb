class Form::Lettings::Questions::Joint < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "joint"
    @check_answer_label = "Is this a joint tenancy?"
    @header = "Is this a joint tenancy?"
    @type = "radio"
    @check_answers_card_number = 0
    @hint_text = form.start_year_after_2024? ? "This is where two or more people are named on the tenancy agreement" : ""
    @answer_options = ANSWER_OPTIONS
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "2" => { "value" => "No" },
    "divider" => { "value" => "true" },
    "3" => { "value" => "Don’t know" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 25 }.freeze
end
