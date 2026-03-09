class Form::Sales::Questions::ServiceCharge < ::Form::Question
  def initialize(id, hsh, page, staircasing:)
    super(id, hsh, page)
    @id = "mscharge"
    @type = "numeric"
    @min = 1
    @max = 9999.99
    @step = 0.01
    @width = 5
    @prefix = "£"
    @copy_key = "sales.sale_information.servicecharges.servicecharge"
    @staircasing = staircasing
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR_AND_SECTION, value_key: subsection.id)
    @strip_commas = true
  end

  QUESTION_NUMBER_FROM_YEAR_AND_SECTION = {
    2025 => 88,
    2026 => { "shared_ownership_initial_purchase" => 88, "shared_ownership_staircasing_transaction" => 88 },
  }
end
