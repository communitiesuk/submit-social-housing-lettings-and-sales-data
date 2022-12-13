module Validations::Sales::SoftValidations
  ALLOWED_INCOME_RANGES = {
    1 => OpenStruct.new(soft_min: 5000),
    2 => OpenStruct.new(soft_min: 1500),
    3 => OpenStruct.new(soft_min: 1000),
    5 => OpenStruct.new(soft_min: 2000),
    0 => OpenStruct.new(soft_min: 2000),
  }.freeze

  def income1_under_soft_min?
    return false unless ecstat1 && income1 && ALLOWED_INCOME_RANGES[ecstat1]

    income1 < ALLOWED_INCOME_RANGES[ecstat1][:soft_min]
  end
end
