module Constants::IncomeRanges
  ALLOWED_INCOME_RANGES = {
    "Full-time - 30 hours or more": OpenStruct.new(soft_min: 143, soft_max: 730, hard_min: 90, hard_max: 1230),
    "Part-time - Less than 30 hours": OpenStruct.new(soft_min: 67, soft_max: 620, hard_min: 50, hard_max: 950),
    "In government training into work, such as New Deal": OpenStruct.new(soft_min: 80, soft_max: 480, hard_min: 40, hard_max: 990),
    "Jobseeker": OpenStruct.new(soft_min: 50, soft_max: 370, hard_min: 10, hard_max: 450),
    "Retired": OpenStruct.new(soft_min: 50, soft_max: 380, hard_min: 10, hard_max: 690),
    "Not seeking work": OpenStruct.new(soft_min: 53, soft_max: 540, hard_min: 10, hard_max: 890),
    "Full-time student": OpenStruct.new(soft_min: 47, soft_max: 460, hard_min: 10, hard_max: 1300),
    "Unable to work because of long term sick or disability": OpenStruct.new(soft_min: 54, soft_max: 460, hard_min: 10, hard_max: 820),
    "Child under 16": OpenStruct.new(soft_min: 50, soft_max: 450, hard_min: 10, hard_max: 750),
    "Other": OpenStruct.new(soft_min: 50, soft_max: 580, hard_min: 10, hard_max: 1040),
    "Prefer not to say": OpenStruct.new(soft_min: 47, soft_max: 730, hard_min: 10, hard_max: 1300),
  }.freeze
end
