class Form::Sales::Questions::DepositAmount < ::Form::Question
  def initialize(id, hsh, subsection, ownershipsch:, optional:)
    super(id, hsh, subsection)
    @id = "deposit"
    @check_answer_label = "Cash deposit"
    @header = "How much cash deposit was paid on the property?"
    @type = "numeric"
    @min = 0
    @max = 999_999
    @step = 1
    @width = 5
    @prefix = "£"
    @ownershipsch = ownershipsch
    @question_number = QUESTION_NUMBER_FROM_YEAR_AND_OWNERSHIP.fetch(form.start_date.year, QUESTION_NUMBER_FROM_YEAR_AND_OWNERSHIP.max_by { |k, _v| k }.last)[ownershipsch]
    @optional = optional
    @top_guidance_partial = "financial_calculations_shared_ownership" if ownershipsch == 1
  end

  def derived?(log)
    log.outright_sale? && !log.mortgage_used?
  end

  QUESTION_NUMBER_FROM_YEAR_AND_OWNERSHIP = {
    2023 => { 1 => 95, 2 => 108, 3 => 116 },
    2024 => { 1 => 96, 2 => 109, 3 => 116 },
  }.freeze

  def hint_text
    if @optional
      "Enter the total cash sum paid by the buyer towards the property that was not funded by the mortgage. This excludes any grant or loan. As this is a fully staircased sale this question is optional. If you do not have the information available click save and continue"
    else
      "Enter the total cash sum paid by the buyer towards the property that was not funded by the mortgage. This excludes any grant or loan"
    end
  end

  def top_guidance_partial
    return "financial_calculations_shared_ownership" if @ownershipsch == 1
    return "financial_calculations_discounted_ownership" if @ownershipsch == 2
  end
end
