class Form::Sales::Questions::Mortgageused < ::Form::Question
  def initialize(id, hsh, page, ownershipsch:)
    super(id, hsh, page)
    @id = "mortgageused"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @ownershipsch = ownershipsch
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR_AND_SECTION, value_key: form.start_year_2025_or_later? ? subsection.id : ownershipsch)
    @top_guidance_partial = top_guidance_partial
  end

  def displayed_answer_options(log, _user = nil)
    if log.outright_sale? && log.saledate && !form.start_year_2024_or_later?
      answer_options_without_dont_know
    elsif log.stairowned_100? || log.outright_sale? || (log.is_staircase? && form.start_year_2025_or_later?)
      ANSWER_OPTIONS
    else
      answer_options_without_dont_know
    end
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "2" => { "value" => "No" },
    "divider" => { "value" => true },
    "3" => { "value" => "Don’t know" },
  }.freeze

  def answer_options_without_dont_know
    ANSWER_OPTIONS.reject { |key, _v| %w[3 divider].include?(key) }
  end

  QUESTION_NUMBER_FROM_YEAR_AND_SECTION = {
    2023 => { 1 => 90, 2 => 103, 3 => 111 },
    2024 => { 1 => 91, 2 => 104, 3 => 112 },
    2025 => { "shared_ownership_initial_purchase" => 82, "shared_ownership_staircasing_transaction" => 99, "discounted_ownership_scheme" => 106 },
    2026 => { "shared_ownership_initial_purchase" => 90, "shared_ownership_staircasing_transaction" => 107, "discounted_ownership_scheme" => 116 },
  }.freeze

  def top_guidance_partial
    return "financial_calculations_shared_ownership" if @ownershipsch == 1
    return "financial_calculations_discounted_ownership" if @ownershipsch == 2

    "financial_calculations_outright_sale" if @ownershipsch == 3
  end
end
