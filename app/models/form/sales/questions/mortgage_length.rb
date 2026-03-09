class Form::Sales::Questions::MortgageLength < ::Form::Question
  def initialize(id, hsh, page, ownershipsch:)
    super(id, hsh, page)
    @id = "mortlen"
    @type = "numeric"
    @min = 0
    @max = 60
    @step = 1
    @width = 5
    @ownershipsch = ownershipsch
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR_AND_SECTION, value_key: form.start_year_2026_or_later? ? subsection.id : ownershipsch)
  end

  def suffix_label(log)
    " #{'year'.pluralize(log[id])}"
  end

  QUESTION_NUMBER_FROM_YEAR_AND_SECTION = {
    2023 => { 1 => 93, 2 => 106, 3 => 114 },
    2024 => { 1 => 94, 2 => 107, 3 => 114 },
    2025 => { 1 => 84, 2 => 108 },
    2026 => { "shared_ownership_initial_purchase" => 84, "discounted_ownership_scheme" => 108 },
  }.freeze
end
