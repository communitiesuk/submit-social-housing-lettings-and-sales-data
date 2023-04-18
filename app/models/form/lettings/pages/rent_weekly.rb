class Form::Lettings::Pages::RentWeekly < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "rent_weekly"
    @header = "Household rent and charges"
    @depends_on = [
      { "rent_and_charges_paid_weekly?" => true, "household_charge" => 0, "is_carehome?" => false },
      { "rent_and_charges_paid_weekly?" => true, "household_charge" => nil, "is_carehome?" => false },
    ]
  end

  def questions
    @questions ||= [
      Form::Lettings::Questions::BrentWeekly.new(nil, nil, self),
      Form::Lettings::Questions::SchargeWeekly.new(nil, nil, self),
      Form::Lettings::Questions::PschargeWeekly.new(nil, nil, self),
      Form::Lettings::Questions::SupchargWeekly.new(nil, nil, self),
      Form::Lettings::Questions::TchargeWeekly.new(nil, nil, self),
    ]
  end
end
