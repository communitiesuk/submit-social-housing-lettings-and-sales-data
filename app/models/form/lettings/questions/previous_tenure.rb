class Form::Lettings::Questions::PreviousTenure < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "prevten"
    @copy_key = "lettings.household_situation.prevten.not_renewal"
    @type = "radio"
    @check_answers_card_number = 0
    @answer_options = form.start_year_2025_or_later? ? ANSWER_OPTIONS_2025 : ANSWER_OPTIONS
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR)
  end

  ANSWER_OPTIONS = {
    "30" => { "value" => "Fixed-term local authority general needs tenancy" },
    "32" => { "value" => "Fixed-term private registered provider (PRP) general needs tenancy" },
    "31" => { "value" => "Lifetime local authority general needs tenancy" },
    "33" => { "value" => "Lifetime private registered provider (PRP) general needs tenancy" },
    "34" => { "value" => "Specialist retirement housing" },
    "36" => { "value" => "Sheltered housing for adults aged under 55 years" },
    "35" => { "value" => "Extra care housing" },
    "6" => { "value" => "Other supported housing" },
    "3" => { "value" => "Private sector tenancy" },
    "27" => { "value" => "Owner occupation (low-cost home ownership)" },
    "26" => { "value" => "Owner occupation (private)" },
    "28" => { "value" => "Living with friends or family" },
    "14" => { "value" => "Bed and breakfast" },
    "7" => { "value" => "Direct access hostel" },
    "10" => { "value" => "Hospital" },
    "29" => { "value" => "Prison or approved probation hostel" },
    "19" => { "value" => "Rough sleeping" },
    "18" => { "value" => "Any other temporary accommodation" },
    "13" => { "value" => "Children’s home or foster care" },
    "24" => { "value" => "Home Office Asylum Support" },
    "37" => { "value" => "Host family or similar refugee accommodation" },
    "23" => { "value" => "Mobile home or caravan" },
    "21" => { "value" => "Refuge" },
    "9" => { "value" => "Residential care home" },
    "4" => { "value" => "Tied housing or rented with job" },
    "25" => { "value" => "Any other accommodation" },
  }.freeze

  ANSWER_OPTIONS_2025 = {
    "30" => { "value" => "Fixed-term local authority general needs tenancy" },
    "32" => { "value" => "Fixed-term private registered provider (PRP) general needs tenancy" },
    "31" => { "value" => "Lifetime local authority general needs tenancy" },
    "33" => { "value" => "Lifetime private registered provider (PRP) general needs tenancy" },
    "35" => { "value" => "Extra care housing" },
    "38" => { "value" => "Older people’s housing for tenants with low support needs" },
    "6" => { "value" => "Other supported housing" },
    "3" => { "value" => "Private sector tenancy" },
    "27" => { "value" => "Owner occupation (low-cost home ownership)" },
    "26" => { "value" => "Owner occupation (private)" },
    "28" => { "value" => "Living with friends or family (long-term)" },
    "39" => { "value" => "Sofa surfing (moving regularly between family or friends, no permanent bed)" },
    "14" => { "value" => "Bed and breakfast" },
    "7" => { "value" => "Direct access hostel" },
    "10" => { "value" => "Hospital" },
    "29" => { "value" => "Prison or approved probation hostel" },
    "19" => { "value" => "Rough sleeping" },
    "18" => { "value" => "Any other temporary accommodation" },
    "13" => { "value" => "Children’s home or foster care" },
    "24" => { "value" => "Home Office Asylum Support" },
    "37" => { "value" => "Host family or similar refugee accommodation" },
    "23" => { "value" => "Mobile home or caravan" },
    "21" => { "value" => "Refuge" },
    "9" => { "value" => "Residential care home" },
    "4" => { "value" => "Tied housing or rented with job" },
    "25" => { "value" => "Any other accommodation" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 78, 2024 => 77, 2025 => 77, 2026 => 84 }.freeze
end
