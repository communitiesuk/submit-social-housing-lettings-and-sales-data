class Form::Lettings::Questions::Prevten < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "prevten"
    @check_answer_label = "Where was the household immediately before this letting?"
    @header = "Where was the household immediately before this letting?"
    @type = "radio"
    @check_answers_card_number = 0
    @hint_text = "This is where the household was the night before they moved."
    @answer_options = ANSWER_OPTIONS
    @question_number = 78
  end

  ANSWER_OPTIONS = {
    "30" => {
      "value" => "Fixed-term local authority general needs tenancy",
    },
    "32" => {
      "value" => "Fixed-term private registered provider (PRP) general needs tenancy",
    },
    "31" => {
      "value" => "Lifetime local authority general needs tenancy",
    },
    "33" => {
      "value" => "Lifetime private registered provider (PRP) general needs tenancy",
    },
    "34" => {
      "value" => "Specialist retirement housing",
    },
    "35" => {
      "value" => "Extra care housing",
    },
    "6" => {
      "value" => "Other supported housing",
    },
    "3" => {
      "value" => "Private sector tenancy",
    },
    "27" => {
      "value" => "Owner occupation (low-cost home ownership)",
    },
    "26" => {
      "value" => "Owner occupation (private)",
    },
    "28" => {
      "value" => "Living with friends or family",
    },
    "14" => {
      "value" => "Bed and breakfast",
    },
    "7" => {
      "value" => "Direct access hostel",
    },
    "10" => {
      "value" => "Hospital",
    },
    "29" => {
      "value" => "Prison or approved probation hostel",
    },
    "19" => {
      "value" => "Rough sleeping",
    },
    "18" => {
      "value" => "Any other temporary accommodation",
    },
    "13" => {
      "value" => "Children’s home or foster care",
    },
    "24" => {
      "value" => "Home Office Asylum Support",
    },
    "23" => {
      "value" => "Mobile home or caravan",
    },
    "21" => {
      "value" => "Refuge",
    },
    "9" => {
      "value" => "Residential care home",
    },
    "4" => {
      "value" => "Tied housing or rented with job",
    },
    "25" => {
      "value" => "Any other accommodation",
    },
  }.freeze
end
