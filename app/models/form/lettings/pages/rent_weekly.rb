class Form::Lettings::Pages::RentWeekly < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "rent_weekly"
    @copy_key = "lettings.income_and_benefits.rent_and_charges"
    @depends_on = depends_on
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

  def depends_on
    if form.start_year_2025_or_later?
      [
        { "rent_and_charges_paid_weekly?" => true, "household_charge" => 0 },
        { "rent_and_charges_paid_weekly?" => true, "household_charge" => nil },
      ]
    else
      [
        { "rent_and_charges_paid_weekly?" => true, "household_charge" => 0, "is_carehome?" => false },
        { "rent_and_charges_paid_weekly?" => true, "household_charge" => nil, "is_carehome?" => false },
      ]
    end
  end
end
