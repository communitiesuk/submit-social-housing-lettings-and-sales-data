class Form::Lettings::Subsections::IncomeAndBenefits < ::Form::Subsection
  def initialize(id, hsh, section)
    super
    @id = "income_and_benefits"
    @label = "Income, benefits and outgoings"
    @depends_on = [{ "non_location_setup_questions_completed?" => true }]
  end

  def pages
    @pages ||= [
      Form::Lettings::Pages::IncomeKnown.new(nil, nil, self),
      Form::Lettings::Pages::IncomeAmount.new(nil, nil, self),
      Form::Lettings::Pages::NetIncomeValueCheck.new(nil, nil, self),
      Form::Lettings::Pages::HousingBenefit.new("housing_benefit", nil, self),
      Form::Lettings::Pages::BenefitsProportion.new("benefits_proportion", nil, self),
      Form::Lettings::Pages::RentOrOtherCharges.new(nil, nil, self),
      Form::Lettings::Pages::RentPeriod.new(nil, nil, self),
      carehome_questions,
      Form::Lettings::Pages::RentWeekly.new(nil, nil, self),
      Form::Lettings::Pages::RentBiWeekly.new(nil, nil, self),
      Form::Lettings::Pages::Rent4Weekly.new(nil, nil, self),
      Form::Lettings::Pages::RentMonthly.new(nil, nil, self),
      Form::Lettings::Pages::RentValueCheck.new("brent_rent_value_check", nil, self, check_answers_card_number: 0),
      Form::Lettings::Pages::SchargeValueCheck.new(nil, nil, self),
      Form::Lettings::Pages::PschargeValueCheck.new(nil, nil, self),
      Form::Lettings::Pages::SupchargValueCheck.new(nil, nil, self),
      Form::Lettings::Pages::Outstanding.new(nil, nil, self),
      Form::Lettings::Pages::OutstandingAmount.new(nil, nil, self),
    ].flatten.compact
  end

private

  def carehome_questions
    return [] if form.start_year_2025_or_later?

    [
      Form::Lettings::Pages::CareHomeWeekly.new(nil, nil, self),
      Form::Lettings::Pages::CareHomeBiWeekly.new(nil, nil, self),
      Form::Lettings::Pages::CareHome4Weekly.new(nil, nil, self),
      Form::Lettings::Pages::CareHomeMonthly.new(nil, nil, self),
      Form::Lettings::Pages::CareHomeChargesValueCheck.new(nil, nil, self),
    ]
  end
end
