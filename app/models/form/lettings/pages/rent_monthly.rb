class Form::Lettings::Pages::RentMonthly < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "rent_monthly"
    @copy_key = "lettings.income_and_benefits.rent_and_charges"
    @depends_on = depends_on
  end

  def questions
    @questions ||= [
      Form::Lettings::Questions::BrentMonthly.new(nil, nil, self),
      Form::Lettings::Questions::SchargeMonthly.new(nil, nil, self),
      Form::Lettings::Questions::PschargeMonthly.new(nil, nil, self),
      Form::Lettings::Questions::SupchargMonthly.new(nil, nil, self),
      Form::Lettings::Questions::TchargeMonthly.new(nil, nil, self),
    ]
  end

  def depends_on
    if form.start_year_2025_or_later?
      [
        { "household_charge" => nil, "rent_and_charges_paid_monthly?" => true },
        { "household_charge" => 0, "rent_and_charges_paid_monthly?" => true },
      ]
    else
      [
        { "household_charge" => nil, "rent_and_charges_paid_monthly?" => true, "is_carehome?" => false },
        { "household_charge" => 0, "rent_and_charges_paid_monthly?" => true, "is_carehome?" => false },
      ]
    end
  end
end
