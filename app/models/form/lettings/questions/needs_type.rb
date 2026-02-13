class Form::Lettings::Questions::NeedsType < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "needstype"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR) if form.start_date.present?
    @top_guidance_partial = "needs_type" if form.start_year_2026_or_later?
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "General needs" },
    "2" => { "value" => "Supported housing" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 3, 2024 => 3, 2025 => 3, 2026 => 3 }.freeze
end
