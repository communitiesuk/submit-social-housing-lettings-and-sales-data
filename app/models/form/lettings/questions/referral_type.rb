class Form::Lettings::Questions::ReferralType < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "referral_type"
    @copy_key = "lettings.household_situation.referral.type"
    @type = "radio"
    @check_answers_card_number = 0
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year]
  end

  def answer_options
    {
      "1" => {
        "value" => "Direct",
      },
      "2" => {
        "value" => "From a local authority housing register or waiting list",
      },
      "3" => {
        "value" => "From a PRP-only housing register or waiting list (no local authority involvement)",
      },
      "4" => {
        "value" => "Health and social care services",
      },
      "5" => {
        "value" => "Police, probation, prison or youth offending team",
      },
      "6" => {
        "value" => "Voluntary agency",
      },
      "7" => {
        "value" => "Other",
      },
    }.freeze
  end

  QUESTION_NUMBER_FROM_YEAR = { 2025 => 84, 2026 => 91 }.freeze
end
