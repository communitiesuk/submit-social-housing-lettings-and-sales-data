class Form::Lettings::Questions::PregOcc < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "preg_occ"
    @check_answer_label = "Anybody in household pregnant"
    @header = "Is anybody in the household pregnant?"
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
    "3" => { "value" => "Tenant prefers not to say" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 69, 2024 => 68 }.freeze
end
