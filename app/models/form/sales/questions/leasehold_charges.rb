class Form::Sales::Questions::LeaseholdCharges < ::Form::Question
  def initialize(id, hsh, page, ownershipsch:)
    super(id, hsh, page)
    @id = "mscharge"
    @type = "numeric"
    @min = 1
    @step = 0.01
    @width = 5
    @prefix = "£"
    @copy_key = "sales.sale_information.leaseholdcharges.mscharge"
    @ownershipsch = ownershipsch
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR_AND_SECTION, value_key: form.start_year_2026_or_later? ? subsection.id : ownershipsch)
    @strip_commas = true
  end

  QUESTION_NUMBER_FROM_YEAR_AND_SECTION = {
    2023 => { 1 => 98, 2 => 109, 3 => 117 },
    2024 => { 1 => 99, 2 => 110, 3 => 117 },
    2025 => { 2 => 111 },
    2026 => { "discounted_ownership_scheme" => 111 },
  }.freeze
end
