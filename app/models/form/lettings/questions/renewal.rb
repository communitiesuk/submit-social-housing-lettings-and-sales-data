class Form::Lettings::Questions::Renewal < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "renewal"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR) if form.start_date.present?
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "0" => { "value" => "No" },
  }
  .freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 4, 2024 => 6, 2025 => 6, 2026 => 6 }.freeze
end
