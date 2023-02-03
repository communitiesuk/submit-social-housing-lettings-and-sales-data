class Form::Lettings::Pages::RentPeriod < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "rent_period"
    @depends_on = [{ "household_charge" => 0 }, { "household_charge" => nil }]
  end

  def questions
    @questions ||= [Form::Lettings::Questions::Period.new(nil, nil, self)]
  end
end
