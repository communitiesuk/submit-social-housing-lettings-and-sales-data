class Form::Lettings::Pages::CareHomeMonthly < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "care_home_monthly"
    @depends_on = [
      { "period" => 4, "needstype" => 2, "household_charge" => 0 },
      { "period" => 4, "needstype" => 2, "household_charge" => nil },
    ]
  end

  def questions
    @questions ||= [
      Form::Lettings::Questions::IsCarehome.new(nil, nil, self),
      Form::Lettings::Questions::ChchargeMonthly.new(nil, nil, self),
    ]
  end
end
