class Form::Lettings::Pages::CareHomeWeekly < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "care_home_weekly"
    @copy_key = "lettings.income_and_benefits.care_home"
    @depends_on = [
      { "rent_and_charges_paid_weekly?" => true, "is_supported_housing?" => true, "household_charge" => 0 },
      { "rent_and_charges_paid_weekly?" => true, "is_supported_housing?" => true, "household_charge" => nil },
    ]
  end

  def questions
    @questions ||= [
      Form::Lettings::Questions::IsCarehome.new(nil, nil, self),
      Form::Lettings::Questions::ChchargeWeekly.new(nil, nil, self),
    ]
  end
end
