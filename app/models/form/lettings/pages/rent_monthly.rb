class Form::Lettings::Pages::RentMonthly < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "rent_monthly"
    @header = "Household rent and charges"
    @depends_on = [{ "household_charge" => 0, "period" => 4, "is_carehome" => 0 }, { "household_charge" => nil, "period" => 4, "is_carehome" => 0 }, { "household_charge" => 0, "period" => 4, "is_carehome" => nil }, { "household_charge" => nil, "period" => 4, "is_carehome" => nil }]
    @description = ""
  end

  def questions
    @questions ||= [Form::Lettings::Questions::BrentMonthly.new(nil, nil, self), Form::Lettings::Questions::Scharge.new(nil, nil, self), Form::Lettings::Questions::Pscharge.new(nil, nil, self), Form::Lettings::Questions::Supcharg.new(nil, nil, self), Form::Lettings::Questions::Tcharge.new(nil, nil, self)]
  end
end
