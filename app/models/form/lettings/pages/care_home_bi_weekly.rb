class Form::Lettings::Pages::CareHomeBiWeekly < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "care_home_bi_weekly"
    @depends_on = [{ "period" => 2, "needstype" => 2, "household_charge" => 0 }, { "period" => 2, "needstype" => 2, "household_charge" => nil }]
  end

  def questions
    @questions ||= [Form::Lettings::Questions::IsCarehome.new(nil, nil, self), Form::Lettings::Questions::ChchargeBiWeekly.new(nil, nil, self)]
  end
end
