class Form::Lettings::Pages::Rent4Weekly < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "rent_4_weekly"
    @copy_key = "lettings.income_and_benefits.rent_and_charges"
    @depends_on = depends_on
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

  def depends_on
    if form.start_year_2025_or_later?
      [
        { "household_charge" => 0, "rent_and_charges_paid_every_4_weeks?" => true },
        { "household_charge" => nil, "rent_and_charges_paid_every_4_weeks?" => true },
      ]
    else
      [
        { "household_charge" => 0, "rent_and_charges_paid_every_4_weeks?" => true, "is_carehome?" => false },
        { "household_charge" => nil, "rent_and_charges_paid_every_4_weeks?" => true, "is_carehome?" => false },
      ]
    end
  end
end
