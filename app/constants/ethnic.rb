module Ethnic
  @@ethnic = {
    "White: English/Scottish/Welsh/Northern Irish/British" => 1,
    "White: Irish" => 2,
    "White: Gypsy/Irish Traveller" => 18,
    "White: Other" => 3,
    "Mixed: White & Black Caribbean" => 4,
    "Mixed: White & Black African" => 5,
    "Mixed: White & Asian" => 6,
    "Mixed: Other" => 7,
    "Asian or Asian British: Indian" => 8,
    "Asian or Asian British: Pakistani" => 9,
    "Asian or Asian British: Bangladeshi" => 10,
    "Asian or Asian British: Chinese" => 15,
    "Asian or Asian British: Other" => 11,
    "Black: Caribbean" => 12,
    "Black: African" => 13,
    "Black: Other" => 14,
    "Other Ethnic Group: Arab" => 16,
    "Other Ethnic Group: Other" => 19,
    "Prefer not to say" => 17,
  }

  def self.ethnic
    @@ethnic
  end
end
