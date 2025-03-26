class Form::Sales::Questions::LeaseholdCharges < ::Form::Question
  def initialize(id, hsh, subsection, ownershipsch:)
    super(id, hsh, subsection)
    @id = "mscharge"
    @type = "numeric"
    @min = 1
    @step = 0.01
    @width = 5
    @prefix = "£"
    @ownershipsch = ownershipsch
    @question_number = QUESTION_NUMBER_FROM_YEAR_AND_OWNERSHIP.fetch(form.start_date.year, QUESTION_NUMBER_FROM_YEAR_AND_OWNERSHIP.max_by { |k, _v| k }.last)[ownershipsch]
  end

  def copy_key
    if form.start_year_2025_or_later?
      case @ownershipsch
      when 1
        "sales.sale_information.monthly_charges.shared_ownership.service_charges.mscharge"
      when 2
        "sales.sale_information.monthly_charges.discounted_ownership.leasehold_charges.mscharge"
      end
    else
      "sales.sale_information.leaseholdcharges.mscharge"
    end
  end

  QUESTION_NUMBER_FROM_YEAR_AND_OWNERSHIP = {
    2023 => { 1 => 98, 2 => 109, 3 => 117 },
    2024 => { 1 => 99, 2 => 110, 3 => 117 },
    2025 => { 1 => 88, 2 => 111 },
  }.freeze
end
