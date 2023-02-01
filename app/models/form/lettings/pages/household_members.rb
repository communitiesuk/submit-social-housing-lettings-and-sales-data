class Form::Lettings::Pages::HouseholdMembers < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "household_members"
    @header = ""
    @depends_on = [{ "declaration" => 1 }]
    @description = ""
  end

  def questions
    @questions ||= [Form::Lettings::Questions::Hhmemb.new(nil, nil, self)]
  end
end
