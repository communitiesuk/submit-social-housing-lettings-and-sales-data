module PreviousTenancy
  @@previous_tenancy = {
    "Owner occupation (private) " => 26,
    "Owner occupation (low cost home ownership)" => 27,
    "Private sector tenancy" => 3,
    "Tied housing or rented with job" => 4,
    "Supported housing" => 5,
    "Sheltered accomodation" => 8,
    "Residential care home" => 9,
    "Living with friends or family" => 28,
    "Refuge" => 21,
    "Hospital" => 10,
    "Prison / approved probation hostel" => 29,
    "Direct access hostel" => 7,
    "Bed & Breakfast" => 14,
    "Mobile home / caravan" => 23,
    "Any other temporary accommodation" => 18,
    "Home Office Asylum Support" => 24,
    "Children’s home / foster care" => 13,
    "Rough sleeping" => 19,
    "Other" => 25,
    "Fixed term Local Authority General Needs tenancy" => 30,
    "Lifetime Local Authority General Needs tenancy" => 31,
    "Fixed term PRP General Needs tenancy" => 32,
    "Lifetime PRP General Needs tenancy" => 33,
  }

  def self.previous_tenancy
    @@previous_tenancy
  end
end
