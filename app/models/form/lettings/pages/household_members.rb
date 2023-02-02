class Form::Lettings::Pages::HouseholdMembers < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "household_members"
    @depends_on = [{ "declaration" => 1 }]
  end

  def questions
    @questions ||= [Form::Lettings::Questions::Hhmemb.new(nil, nil, self)]
  end
end
