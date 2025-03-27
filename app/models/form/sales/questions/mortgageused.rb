class Form::Sales::Questions::Mortgageused < ::Form::Question
  def initialize(id, hsh, subsection, ownershipsch:)
    super(id, hsh, subsection)
    @id = "mortgageused"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @ownershipsch = ownershipsch
    @question_number = question_number_from_year_and_ownership.fetch(form.start_date.year, question_number_from_year_and_ownership.max_by { |k, _v| k }.last)[ownershipsch]
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

  def question_number_from_year_and_ownership
    {
      2023 => { 1 => 90, 2 => 103, 3 => 111 },
      2024 => { 1 => 91, 2 => 104, 3 => 112 },
      2025 => { 1 => subsection.id == "shared_ownership_staircasing_transaction" ? 99 : 82, 2 => 106 },
    }
  end

  def top_guidance_partial
    return "financial_calculations_shared_ownership" if @ownershipsch == 1
    return "financial_calculations_discounted_ownership" if @ownershipsch == 2
    return "financial_calculations_outright_sale" if @ownershipsch == 3
  end
end
