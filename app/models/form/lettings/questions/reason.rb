class Form::Lettings::Questions::Reason < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "reason"
    @copy_key = "lettings.household_situation.reason.#{page.id}.reason"
    @type = "radio"
    @check_answers_card_number = 0
    @conditional_for = {
      "reasonother" => [
        20,
      ],
    }
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year]
  end

  def answer_options
    if form.start_year_2026_or_later?
      QUESTIONS_FROM_YEAR[2026]
    elsif form.start_year_2025_or_later?
      QUESTIONS_FROM_YEAR[2025]
    else
      QUESTIONS_FROM_YEAR[2024]
    end
  end

  QUESTIONS_FROM_YEAR = {
    2026 => {
      "50" => { "value" => "End of social or private sector tenancy - no fault" },
      "51" => { "value" => "End of social or private sector tenancy - evicted due to anti-social behaviour (ASB)" },
      "52" => { "value" => "End of social or private sector tenancy - evicted due to rent arrears" },
      "53" => { "value" => "End of social or private sector tenancy - evicted for any other reason" },
      "1" => { "value" => "Permanently decanted from another property owned by this landlord" },
      "2" => { "value" => "Left home country as a refugee" },
      "45" => { "value" => "Discharged from prison" },
      "46" => { "value" => "Discharged from long-stay hospital or similar institution" },
      "4" => { "value" => "Loss of tied accommodation" },
      "55" => { "value" => "Leaving foster care or children's home" },
      "9" => { "value" => "Asked to leave by family or friends" },
      "8" => { "value" => "Relationship breakdown (non-violent) with partner" },
      "44" => { "value" => "Death of household member in last settled accommodation" },
      "16" => { "value" => "To move nearer to family, friends or school" },
      "17" => { "value" => "To move nearer to work" },
      "48" => { "value" => "Domestic abuse - previously joint tenancy with partner" },
      "49" => { "value" => "Domestic abuse - other" },
      "56" => { "value" => "Non-domestic violence (e.g. gang violence)" },
      "57" => { "value" => "Cuckooing (property being used by others for illegal activity)" },
      "10" => { "value" => "Racial harassment" },
      "31" => { "value" => "Hate crime" },
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
      "47" => { "value" => "Tenant prefers not to say" },
      "20" => { "value" => "Other" },
      "divider" => { "value" => true },
      "28" => { "value" => "Don’t know" },
    }.freeze,
    2025 => {
      "50" => { "value" => "End of social or private sector tenancy - no fault" },
      "51" => { "value" => "End of social or private sector tenancy - evicted due to anti-social behaviour (ASB)" },
      "52" => { "value" => "End of social or private sector tenancy - evicted due to rent arrears" },
      "53" => { "value" => "End of social or private sector tenancy - evicted for any other reason" },
      "1" => { "value" => "Permanently decanted from another property owned by this landlord" },
      "2" => { "value" => "Left home country as a refugee" },
      "45" => { "value" => "Discharged from prison" },
      "46" => { "value" => "Discharged from long-stay hospital or similar institution" },
      "4" => { "value" => "Loss of tied accommodation" },
      "55" => { "value" => "Leaving foster care or children's home" },
      "9" => { "value" => "Asked to leave by family or friends" },
      "8" => { "value" => "Relationship breakdown (non-violent) with partner" },
      "44" => { "value" => "Death of household member in last settled accommodation" },
      "16" => { "value" => "To move nearer to family, friends or school" },
      "17" => { "value" => "To move nearer to work" },
      "48" => { "value" => "Domestic abuse - previously joint tenancy with partner" },
      "49" => { "value" => "Domestic abuse - other" },
      "10" => { "value" => "Racial harassment" },
      "31" => { "value" => "Hate crime" },
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
      "47" => { "value" => "Tenant prefers not to say" },
      "20" => { "value" => "Other" },
      "divider" => { "value" => true },
      "28" => { "value" => "Don’t know" },
    }.freeze,
    2024 => {
      "50" => { "value" => "End of social or private sector tenancy - no fault" },
      "51" => { "value" => "End of social or private sector tenancy - evicted due to anti-social behaviour (ASB)" },
      "52" => { "value" => "End of social or private sector tenancy - evicted due to rent arrears" },
      "53" => { "value" => "End of social or private sector tenancy - evicted for any other reason" },
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
      "31" => { "value" => "Hate crime" },
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
      "47" => { "value" => "Tenant prefers not to say" },
      "divider" => { "value" => true },
      "28" => { "value" => "Don’t know" },
    }.freeze,
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2024 => 76, 2025 => 76, 2026 => 75 }.freeze
end
