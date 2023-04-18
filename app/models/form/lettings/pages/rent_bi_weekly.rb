class Form::Lettings::Pages::RentBiWeekly < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "rent_bi_weekly"
    @header = "Household rent and charges"
    @depends_on = [
      { "household_charge" => nil, "rent_and_charges_paid_every_2_weeks?" => true, "is_carehome?" => false },
      { "household_charge" => 0, "rent_and_charges_paid_every_2_weeks?" => true, "is_carehome?" => false },
    ]
  end

  def questions
    @questions ||= [
      Form::Lettings::Questions::BrentBiWeekly.new(nil, nil, self),
      Form::Lettings::Questions::SchargeBiWeekly.new(nil, nil, self),
      Form::Lettings::Questions::PschargeBiWeekly.new(nil, nil, self),
      Form::Lettings::Questions::SupchargBiWeekly.new(nil, nil, self),
      Form::Lettings::Questions::TchargeBiWeekly.new(nil, nil, self),
    ]
  end
end
