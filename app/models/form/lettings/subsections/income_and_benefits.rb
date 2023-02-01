class Form::Lettings::Subsections::IncomeAndBenefits < ::Form::Subsection
  def initialize(id, hsh, section)
    super
    @id = "income_and_benefits"
    @label = "Income, benefits and outgoings"
    @depends_on = [{ "non_location_setup_questions_completed?" => true }]
  end

  def pages
    @pages ||= [Form::Lettings::Pages::IncomeKnown.new(nil, nil, self),
                Form::Lettings::Pages::IncomeAmount.new(nil, nil, self),
                Form::Lettings::Pages::NetIncomeValueCheck.new(nil, nil, self),
                Form::Lettings::Pages::HousingBenefit.new(nil, nil, self),
                Form::Lettings::Pages::BenefitsProportion.new(nil, nil, self),
                Form::Lettings::Pages::RentOrOtherCharges.new(nil, nil, self),
                Form::Lettings::Pages::RentPeriod.new(nil, nil, self),
                Form::Lettings::Pages::CareHomeWeekly.new(nil, nil, self),
                Form::Lettings::Pages::CareHomeBiWeekly.new(nil, nil, self),
                Form::Lettings::Pages::CareHome4Weekly.new(nil, nil, self),
                Form::Lettings::Pages::CareHomeMonthly.new(nil, nil, self),
                Form::Lettings::Pages::RentWeekly.new(nil, nil, self),
                Form::Lettings::Pages::RentBiWeekly.new(nil, nil, self),
                Form::Lettings::Pages::Rent4Weekly.new(nil, nil, self),
                Form::Lettings::Pages::RentMonthly.new(nil, nil, self),
                Form::Lettings::Pages::MinRentValueCheck.new(nil, nil, self),
                Form::Lettings::Pages::MaxRentValueCheck.new(nil, nil, self),
                Form::Lettings::Pages::Outstanding.new(nil, nil, self),
                Form::Lettings::Pages::OutstandingAmount.new(nil, nil, self)].compact
  end
end
