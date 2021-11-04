module DbEnums
  def self.benefitcap
    {
      "Yes - benefit cap" => 5,
      "Yes - removal of the spare room subsidy" => 4,
      "Yes - both the benefit cap and the removal of the spare room subsidy" => 6,
      "No" => 2,
      "Do not know" => 3,
      "Prefer not to say" => 100,
    }
  end

  def self.ecstat
    {
      "Part-time - Less than 30 hours" => 2,
      "Full-time - 30 hours or more" => 1,
      "In government training into work, such as New Deal" => 3,
      "Jobseeker" => 4,
      "Retired" => 5,
      "Not seeking work" => 6,
      "Full-time student" => 7,
      "Unable to work because of long term sick or disability" => 8,
      "Child under 16" => 100,
      "Other" => 0,
      "Prefer not to say" => 10,
    }
  end

  def self.ethnic
    {
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
  end

  def self.homeless
    {
      "Yes - assessed as homeless by a local authority and owed a homelessness duty. Including if threatened with homelessness within 56 days" => 11,
      "Yes - other homelessness" => 7,
      "No" => 1,
    }
  end

  def self.illness
    {
      "Yes" => 1,
      "No" => 2,
      "Do not know" => 3,
      "Prefer not to say" => 100,
    }
  end

  def self.leftreg
    {
      "Yes" => 6,
      "No - they left up to 5 years ago" => 4,
      "No - they left more than 5 years ago" => 5,
      "Prefer not to say" => 3,
    }
  end

  def self.national
    {
      "UK national resident in UK" => 1,
      "A current or former reserve in the UK Armed Forces (exc. National Service)" => 100,
      "UK national returning from residence overseas" => 2,
      "Czech Republic" => 3,
      "Estonia" => 4,
      "Hungary" => 5,
      "Latvia" => 6,
      "Lithuania" => 7,
      "Poland" => 8,
      "Slovakia" => 9,
      "Bulgaria" => 14,
      "Romania" => 15,
      "Ireland" => 17,
      "Other EU Economic Area (EEA country)" => 11,
      "Any other country" => 12,
      "Prefer not to say" => 13,
    }
  end

  def self.pregnancy
    {
      "Yes" => 1,
      "No" => 2,
      "Prefer not to say" => 3,
    }
  end

  def self.previous_tenancy
    {
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
  end

  def self.reservist
    {
      "Yes" => 1,
      "No" => 2,
      "Prefer not to say" => 3,
    }
  end

  def self.polar
    {
      "No" => 0,
      "Yes" => 1,
    }
  end

  def self.polar2
    {
      "No" => 2,
      "Yes" => 1,
    }
  end

  def self.tenancy
    {
      "Fixed term – Secure" => 1,
      "Fixed term – Assured Shorthold Tenancy (AST)" => 4,
      "Lifetime – Secure" => 100,
      "Lifetime – Assured" => 2,
      "License agreement" => 5,
      "Other" => 3,
    }
  end

  def self.landlord
    {
      "This landlord" => 1,
      "Another registered provider - includes housing association or local authority" => 2,
    }
  end

  def self.rsnvac
    {
      "First let of newbuild property" => 15,
      "First let of conversion/rehabilitation/acquired property" => 16,
      "First let of leased property" => 17,
      "Relet - tenant evicted due to arrears" => 10,
      "Relet - tenant evicted due to ASB or other reason" => 11,
      "Relet - tenant died (no succession)" => 5,
      "Relet - tenant moved to other social housing provider" => 12,
      "Relet - tenant abandoned property" => 6,
      "Relet - tenant moved to private sector or other accommodation" => 8,
      "Relet - to tenant who occupied same property as temporary accommodation" => 9,
      "Relet – internal transfer (excluding renewals of a fixed-term tenancy)" => 13,
      "Relet – renewal of fixed-term tenancy" => 14,
      "Relet – tenant moved to care home" => 18,
      "Relet – tenant involved in a succession downsize" => 19,
    }
  end
end
