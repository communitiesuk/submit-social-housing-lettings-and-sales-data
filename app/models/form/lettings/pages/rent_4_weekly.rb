class Form::Lettings::Pages::Rent4Weekly < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "rent_4_weekly"
    @header = "Household rent and charges"
    @depends_on = [{ "household_charge" => 0, "period" => 3, "is_carehome" => 0 }, { "household_charge" => nil, "period" => 3, "is_carehome" => 0 }, { "household_charge" => 0, "period" => 3, "is_carehome" => nil }, { "household_charge" => nil, "period" => 3, "is_carehome" => nil }]
    @description = ""
  end

  def questions
    @questions ||= [Form::Lettings::Questions::Brent4Weekly.new(nil, nil, self),
                    Form::Lettings::Questions::Scharge4Weekly.new(nil, nil, self),
                    Form::Lettings::Questions::Pscharge4Weekly.new(nil, nil, self),
                    Form::Lettings::Questions::Supcharg4Weekly.new(nil, nil, self),
                    Form::Lettings::Questions::Tcharge4Weekly.new(nil, nil, self)]
  end
end
