class Form::Sales::Questions::ExtraBorrowing < ::Form::Question
  def initialize(id, hsh, page, ownershipsch:)
    super(id, hsh, page)
    @id = "extrabor"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @page = page
    @ownershipsch = ownershipsch
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR_AND_SECTION, value_key: form.start_year_2026_or_later? ? subsection.id : ownershipsch)
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "2" => { "value" => "No" },
    "divider" => { "value" => true },
    "3" => { "value" => "Don’t know" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR_AND_SECTION = {
    2023 => { 1 => 94, 2 => 107, 3 => 115 },
    2024 => { 1 => 95, 2 => 108, 3 => 115 },
    2025 => { 2 => 109 },
    2026 => { "discounted_ownership_scheme" => 109 },
  }.freeze
end
