class Form::Lettings::Pages::CareHomeMonthly < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "care_home_monthly"
    @header = ""
    @depends_on = [{ "period" => 4, "needstype" => 2, "household_charge" => 0 }, { "period" => 4, "needstype" => 2, "household_charge" => nil }]
    @description = ""
  end

  def questions
    @questions ||= [Form::Lettings::Questions::IsCarehome.new(nil, nil, self), Form::Lettings::Questions::Chcharge.new(nil, nil, self)]
  end
end
