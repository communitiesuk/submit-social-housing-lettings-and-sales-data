class Form::Lettings::Pages::CareHomeWeekly < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "care_home_weekly"
    @depends_on = [{ "period" => 1, "needstype" => 2, "household_charge" => 0 }, { "period" => 1, "needstype" => 2, "household_charge" => nil }, { "period" => 5, "needstype" => 2, "household_charge" => 0 }, { "period" => 5, "needstype" => 2, "household_charge" => nil }, { "period" => 6, "needstype" => 2, "household_charge" => 0 }, { "period" => 6, "needstype" => 2, "household_charge" => nil }, { "period" => 7, "needstype" => 2, "household_charge" => 0 }, { "period" => 7, "needstype" => 2, "household_charge" => nil }, { "period" => 8, "needstype" => 2, "household_charge" => 0 }, { "period" => 8, "needstype" => 2, "household_charge" => nil }, { "period" => 9, "needstype" => 2, "household_charge" => 0 }, { "period" => 9, "needstype" => 2, "household_charge" => nil }]
  end

  def questions
    @questions ||= [Form::Lettings::Questions::IsCarehome.new(nil, nil, self), Form::Lettings::Questions::ChchargeWeekly.new(nil, nil, self)]
  end
end
