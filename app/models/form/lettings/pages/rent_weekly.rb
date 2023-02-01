class Form::Lettings::Pages::RentWeekly < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "rent_weekly"
    @header = "Household rent and charges"
    @depends_on = [{ "period" => 1, "household_charge" => 0, "is_carehome" => 0 }, { "period" => 1, "household_charge" => nil, "is_carehome" => 0 }, { "period" => 5, "household_charge" => 0, "is_carehome" => 0 }, { "period" => 5, "household_charge" => nil, "is_carehome" => 0 }, { "period" => 6, "household_charge" => 0, "is_carehome" => 0 }, { "period" => 6, "household_charge" => nil, "is_carehome" => 0 }, { "period" => 7, "household_charge" => 0, "is_carehome" => 0 }, { "period" => 7, "household_charge" => nil, "is_carehome" => 0 }, { "period" => 8, "household_charge" => 0, "is_carehome" => 0 }, { "period" => 8, "household_charge" => nil, "is_carehome" => 0 }, { "period" => 9, "household_charge" => 0, "is_carehome" => 0 }, { "period" => 9, "household_charge" => nil, "is_carehome" => 0 }, { "period" => 1, "household_charge" => 0, "is_carehome" => nil }, { "period" => 1, "household_charge" => nil, "is_carehome" => nil }, { "period" => 5, "household_charge" => 0, "is_carehome" => nil }, { "period" => 5, "household_charge" => nil, "is_carehome" => nil }, { "period" => 6, "household_charge" => 0, "is_carehome" => nil }, { "period" => 6, "household_charge" => nil, "is_carehome" => nil }, { "period" => 7, "household_charge" => 0, "is_carehome" => nil }, { "period" => 7, "household_charge" => nil, "is_carehome" => nil }, { "period" => 8, "household_charge" => 0, "is_carehome" => nil }, { "period" => 8, "household_charge" => nil, "is_carehome" => nil }, { "period" => 9, "household_charge" => 0, "is_carehome" => nil }, { "period" => 9, "household_charge" => nil, "is_carehome" => nil }]
    @description = ""
  end

  def questions
    @questions ||= [Form::Lettings::Questions::BrentWeekly.new(nil, nil, self),
                    Form::Lettings::Questions::SchargeWeekly.new(nil, nil, self),
                    Form::Lettings::Questions::Pscharge.new(nil, nil, self),
                    Form::Lettings::Questions::Supcharg.new(nil, nil, self),
                    Form::Lettings::Questions::Tcharge.new(nil, nil, self)]
  end
end
