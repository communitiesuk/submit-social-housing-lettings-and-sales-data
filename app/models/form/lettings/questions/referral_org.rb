# added in 2026
class Form::Lettings::Questions::ReferralOrg < ::Form::Question
  def initialize(id, hsh, page, referral_noms)
    super(id, hsh, page)
    @id = "referral_org"
    @copy_key = "lettings.household_situation.referral.org"
    @type = "radio"
    @check_answers_card_number = 0
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR)
    @referral_noms = referral_noms
  end

  def answer_options
    case @referral_noms
    when 1
      {
        "1" => {
          "value" => "Referred to LA by health service",
        },
        "2" => {
          "value" => "Referred to LA by community learning disability team",
        },
        "3" => {
          "value" => "Referred to LA by community mental health team",
        },
        "4" => {
          "value" => "Referred to LA by adult social services",
        },
        "5" => {
          "value" => "Referred to LA by children's social care",
        },
        "6" => {
          "value" => "Referred to LA by police, probation, prison or youth offending team following a custodial sentence",
        },
        "7" => {
          "value" => "Referred to LA by police, probation, prison or youth offending team without a custodial sentence",
        },
        "8" => {
          "value" => "Referred to LA by a voluntary agency",
        },
        "9" => {
          "value" => "Other referral",
        },
        "10" => {
          "value" => "Don't know",
        },
      }.freeze
    when 7
      {
        "11" => {
          "value" => "Health service",
        },
        "12" => {
          "value" => "Community learning disability team",
        },
        "13" => {
          "value" => "Community mental health team",
        },
        "14" => {
          "value" => "Adult social services",
        },
        "15" => {
          "value" => "Children's social care",
        },
        "16" => {
          "value" => "Police, probation, prison or youth offending team following a custodial sentence",
        },
        "17" => {
          "value" => "Police, probation, prison or youth offending team without a custodial sentence",
        },
        "18" => {
          "value" => "Voluntary agency",
        },
        "19" => {
          "value" => "Other third party",
        },
        "20" => {
          "value" => "Don't know",
        },
      }.freeze
    end
  end

  QUESTION_NUMBER_FROM_YEAR = { 2026 => 92 }.freeze
end
