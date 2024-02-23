class Form::Lettings::Questions::Reason < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "reason"
    @check_answer_label = "Reason for leaving last settled home"
    @header = "What is the tenant’s main reason for the household leaving their last settled home?"
    @type = "radio"
    @check_answers_card_number = 0
    @hint_text = form.start_year_after_2024? ? "The tenant’s ‘last settled home’ is their last long-standing home. For tenants who were in temporary accommodation, sleeping rough or otherwise homeless, their last settled home is where they were living previously." : "The tenant’s ‘last settled home’ is their last long-standing home. For tenants who were in temporary accommodation or sleeping rough, their last settled home is where they were living previously."
    @conditional_for = {
      "reasonother" => [
        20,
      ],
    }
    @question_number = QUESTION_NUMBER_FROM_YEAR.fetch(form.start_date.year, QUESTION_NUMBER_FROM_YEAR.max_by { |k, _v| k }.last)
  end

  def answer_options
    if form.start_year_after_2024?
      {
        "50" => { "value" => "End of social housing tenancy - no fault" },
        "51" => { "value" => "End of social housing tenancy - evicted due to anti-social behaviour (ASB)" },
        "52" => { "value" => "End of social housing tenancy - evicted due to rent arrears" },
        "53" => { "value" => "End of social housing tenancy - evicted for any other reason" },
        "1" => { "value" => "Permanently decanted from another property owned by this landlord" },
        "2" => { "value" => "Left home country as a refugee" },
        "45" => { "value" => "Discharged from prison" },
        "46" => { "value" => "Discharged from long-stay hospital or similar institution" },
        "4" => { "value" => "Loss of tied accommodation" },
        "9" => { "value" => "Asked to leave by family or friends" },
        "8" => { "value" => "Relationship breakdown (non-violent) with partner" },
        "44" => { "value" => "Death of household member in last settled accommodation" },
        "16" => { "value" => "To move nearer to family, friends or school" },
        "17" => { "value" => "To move nearer to work" },
        "48" => { "value" => "Domestic abuse - previously joint tenancy with partner" },
        "49" => { "value" => "Domestic abuse - other" },
        "10" => { "value" => "Racial harassment" },
        "31" => { "value" => "Hate crime"        },
        "11" => { "value" => "Other problems with neighbours" },
        "34" => { "value" => "Repossession" },
        "54" => { "value" => "Could no longer afford rent or mortgage" },
        "12" => { "value" => "Property unsuitable because of overcrowding" },
        "13" => { "value" => "Property unsuitable because of ill health or disability" },
        "14" => { "value" => "Property unsuitable because of poor condition" },
        "29" => { "value" => "Under occupation (offered incentive to downsize)" },
        "30" => { "value" => "Under occupation (no incentive)" },
        "18" => { "value" => "To move to accommodation with support" },
        "19" => { "value" => "To move to independent accommodation" },
        "20" => { "value" => "Other" },
        "28" => { "value" => "Don’t know" },
        "divider" => { "value" => true },
        "47" => { "value" => "Tenant prefers not to say" },
      }.freeze
    else
      {
        "40" => { "value" => "End of assured shorthold tenancy (no fault)" },
        "41" => { "value" => "End of assured shorthold tenancy (eviction or tenant at fault)" },
        "42" => { "value" => "End of fixed term tenancy (no fault)" },
        "43" => { "value" => "End of fixed term tenancy (eviction or tenant at fault)" },
        "1" => { "value" => "Permanently decanted from another property owned by this landlord" },
        "46" => { "value" => "Discharged from long-stay hospital or similar institution" },
        "45" => { "value" => "Discharged from prison" },
        "2" => { "value" => "Left home country as a refugee" },
        "4" => { "value" => "Loss of tied accommodation" },
        "9" => { "value" => "Asked to leave by family or friends" },
        "44" => { "value" => "Death of household member in last settled accommodation" },
        "8" => { "value" => "Relationship breakdown (non-violent) with partner" },
        "16" => { "value" => "To move nearer to family, friends or school" },
        "17" => { "value" => "To move nearer to work" },
        "48" => { "value" => "Domestic abuse - previously joint tenancy with partner" },
        "49" => { "value" => "Domestic abuse - other" },
        "31" => { "value" => "Hate crime" },
        "10" => { "value" => "Racial harassment" },
        "11" => { "value" => "Other problems with neighbours" },
        "35" => { "value" => "Couldn’t afford fees attached to renewing the tenancy" },
        "36" => { "value" => "Couldn’t afford increase in rent" },
        "38" => { "value" => "Couldn’t afford rent or mortgage (employment)" },
        "37" => { "value" => "Couldn’t afford rent or mortgage (welfare reforms)" },
        "39" => { "value" => "Couldn’t afford rent or mortgage (other)" },
        "34" => { "value" => "Repossession" },
        "12" => { "value" => "Property unsuitable because of overcrowding" },
        "13" => { "value" => "Property unsuitable because of ill health or disability" },
        "14" => { "value" => "Property unsuitable because of poor condition" },
        "18" => { "value" => "To move to accommodation with support" },
        "19" => { "value" => "To move to independent accommodation" },
        "30" => { "value" => "Under occupation (no incentive)" },
        "29" => { "value" => "Under occupation (offered incentive to downsize)" },
        "20" => { "value" => "Other" },
        "47" => { "value" => "Tenant prefers not to say" },
        "divider" => { "value" => true },
        "28" => { "value" => "Don’t know" },
      }.freeze
    end
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 77, 2024 => 76 }.freeze
end
