# added in 2026
class Form::Lettings::Questions::ReferralRegister < ::Form::Question
  def initialize(id, hsh, page, provider_type)
    super(id, hsh, page)
    @id = "referral_register"
    @copy_key = "lettings.household_situation.referral.register"
    @type = "radio"
    @check_answers_card_number = 0
    @provider_type = provider_type
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year]
    @question_number += 1 if @provider_type == :prp
  end

  def answer_options
    if @provider_type == :la
      {
        "1" => {
          "value" => "Renewal to the same tenant in the same property",
        },
        "2" => {
          "value" => "Internal transfer from another property owned by the same local authority - for existing social tenants only",
        },
        "3" => {
          "value" => "From a housing register (waiting list)",
        },
        "4" => {
          "value" => "Tenant applied directly (not via a nomination or housing register)",
        },
      }.freeze
    else
      {
        "5" => {
          "value" => "Renewal to the same tenant in the same property",
        },
        "6" => {
          "value" => "From a local authority housing register (waiting list) or a register with local authority involvement",
        },
        "7" => {
          "value" => "From a housing register (waiting list) with no local authority involvement",
        },
        "8" => {
          "value" => "Tenant applied directly (not via a nomination or waiting list)",
        },
        "9" => {
          "value" => "Don't know",
        },
      }.freeze
    end
  end

  def derived?(log)
    log.is_renewal?
  end

  QUESTION_NUMBER_FROM_YEAR = { 2026 => 91 }.freeze
end
