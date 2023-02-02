class Form::Lettings::Pages::CareHome4Weekly < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "care_home_4_weekly"
    @depends_on = [
      { "period" => 3, "needstype" => 2, "household_charge" => 0 },
      { "period" => 3, "needstype" => 2, "household_charge" => nil },
    ]
  end

  def questions
    @questions ||= [
      Form::Lettings::Questions::IsCarehome.new(nil, nil, self),
      Form::Lettings::Questions::Chcharge4Weekly.new(nil, nil, self),
    ]
  end
end
