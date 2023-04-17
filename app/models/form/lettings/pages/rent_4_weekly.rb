class Form::Lettings::Pages::Rent4Weekly < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "rent_4_weekly"
    @header = "Household rent and charges"
    @depends_on = [
      { "household_charge" => 0, "rent_and_charges_paid_every_4_weeks?" => true, "is_carehome?" => false },
      { "household_charge" => nil, "rent_and_charges_paid_every_4_weeks?" => true, "is_carehome?" => false },
    ]
  end

  def questions
    @questions ||= [
      Form::Lettings::Questions::Brent4Weekly.new(nil, nil, self),
      Form::Lettings::Questions::Scharge4Weekly.new(nil, nil, self),
      Form::Lettings::Questions::Pscharge4Weekly.new(nil, nil, self),
      Form::Lettings::Questions::Supcharg4Weekly.new(nil, nil, self),
      Form::Lettings::Questions::Tcharge4Weekly.new(nil, nil, self),
    ]
  end
end
