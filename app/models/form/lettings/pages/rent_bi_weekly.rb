class Form::Lettings::Pages::RentBiWeekly < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "rent_bi_weekly"
    @copy_key = "lettings.income_and_benefits.rent_and_charges"
    @depends_on = depends_on
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

  def depends_on
    if form.start_year_2025_or_later?
      [
        { "household_charge" => nil, "rent_and_charges_paid_every_2_weeks?" => true },
        { "household_charge" => 0, "rent_and_charges_paid_every_2_weeks?" => true },
      ]
    else
      [
        { "household_charge" => nil, "rent_and_charges_paid_every_2_weeks?" => true, "is_carehome?" => false },
        { "household_charge" => 0, "rent_and_charges_paid_every_2_weeks?" => true, "is_carehome?" => false },
      ]
    end
  end
end
