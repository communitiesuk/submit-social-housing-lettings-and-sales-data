class Form::Lettings::Questions::PregOcc < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "preg_occ"
    @type = "radio"
    @check_answers_card_number = 0
    @answer_options = ANSWER_OPTIONS
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year]
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "2" => { "value" => "No" },
    "divider" => { "value" => true },
    "3" => { "value" => "Tenant prefers not to say" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 69, 2024 => 68, 2025 => 68, 2026 => 75 }.freeze
end
