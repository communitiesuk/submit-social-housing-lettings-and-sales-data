class Form::Sales::Questions::Mortgageused < ::Form::Question
  def initialize(id, hsh, subsection, ownershipsch:)
    super(id, hsh, subsection)
    @id = "mortgageused"
    @copy_key = "sales.sale_information.mortgageused"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @ownershipsch = ownershipsch
    @question_number = QUESTION_NUMBER_FROM_YEAR_AND_OWNERSHIP.fetch(form.start_date.year, QUESTION_NUMBER_FROM_YEAR_AND_OWNERSHIP.max_by { |k, _v| k }.last)[ownershipsch]
    @top_guidance_partial = top_guidance_partial
  end

  def displayed_answer_options(log, _user = nil)
    if log.outright_sale? && log.saledate && !form.start_year_2024_or_later?
      answer_options_without_dont_know
    elsif log.stairowned == 100 || log.outright_sale? || form.start_year_2025_or_later?
      ANSWER_OPTIONS
    else
      answer_options_without_dont_know
    end
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "2" => { "value" => "No" },
    "3" => { "value" => "Don’t know" },
  }.freeze

  def answer_options_without_dont_know
    ANSWER_OPTIONS.reject { |key, _v| key == "3" }
  end

  QUESTION_NUMBER_FROM_YEAR_AND_OWNERSHIP = {
    2023 => { 1 => 90, 2 => 103, 3 => 111 },
    2024 => { 1 => 91, 2 => 104, 3 => 112 },
  }.freeze

  def top_guidance_partial
    return "financial_calculations_shared_ownership" if @ownershipsch == 1
    return "financial_calculations_discounted_ownership" if @ownershipsch == 2
    return "financial_calculations_outright_sale" if @ownershipsch == 3
  end
end
