class Form::Lettings::Pages::RentPeriod < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "rent_period"
    @depends_on = [{ "needstype" => 1 }, { "needstype" => 2, "household_charge" => 0 }, { "needstype" => 2, "household_charge" => nil }]
  end

  def questions
    @questions ||= [Form::Lettings::Questions::Period.new(nil, nil, self)]
  end
end
