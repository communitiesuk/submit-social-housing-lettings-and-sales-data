class Form::Lettings::Questions::Renewal < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "renewal"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @hint_text = hint_text
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max] if form.start_date.present?
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "0" => { "value" => "No" },
  }
  .freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 4, 2024 => 6 }.freeze
end
