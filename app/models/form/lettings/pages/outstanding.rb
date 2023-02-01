class Form::Lettings::Pages::Outstanding < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "outstanding"
    @header = ""
    @depends_on = [{ "hb" => 1, "household_charge" => 0 }, { "hb" => 1, "household_charge" => nil }, { "hb" => 6, "household_charge" => 0 }, { "hb" => 6, "household_charge" => nil }]
    @description = ""
  end

  def questions
    @questions ||= [Form::Lettings::Questions::Hbrentshortfall.new(nil, nil, self)]
  end
end
