class Form::Lettings::Questions::Housingneeds < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "housingneeds"
    @check_answer_label = "Anybody with disabled access needs"
    @header = "Does anybody in the household have any disabled access needs?"
    @type = "radio"
    @check_answers_card_number = 0
    @hint_text = ""
    @answer_options = ANSWER_OPTIONS
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "2" => { "value" => "No" },
    "divider" => { "value" => true },
    "3" => { "value" => "Don’t know" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 70, 2024 => 69 }.freeze
end
