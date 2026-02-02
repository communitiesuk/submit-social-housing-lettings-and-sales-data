# added in 2026
class Form::Lettings::Questions::ReferralNoms < ::Form::Question
  def initialize(id, hsh, page, referral_register)
    super(id, hsh, page)
    @id = "referral_noms"
    @copy_key = "lettings.household_situation.referral.noms"
    @type = "radio"
    @check_answers_card_number = 0
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
    @referral_register = referral_register
  end

  def answer_options
    case @referral_register
    when 6
      {
        "1" => {
          "value" => "Nominated by a local authority to a PRP",
        },
        "2" => {
          "value" => "Supported housing only - referred by a local authority to a PRP",
        },
        "3" => {
          "value" => "Internal transfer from another property owned by the same PRP landlord - for existing social tenants only",
        },
        "4" => {
          "value" => "Other",
        },
      }.freeze
    when 7
      {
        "5" => {
          "value" => "Internal transfer from another property owned by the same PRP landlord - for existing social tenants only",
        },
        "6" => {
          "value" => " A different PRP landlord - for existing social tenants only",
        },
        "7" => {
          "value" => "Directly referred by a third party",
        },
        "8" => {
          "value" => "Other",
        },
      }.freeze
    end
  end

  QUESTION_NUMBER_FROM_YEAR = { 2026 => 84 }.freeze
end
