class Form::Lettings::Sections::Household < ::Form::Section
  def initialize(id, hsh, form)
    super
    @id = "household"
    @label = "About the household"
    @form = form
    @subsections = [
      Form::Lettings::Subsections::HouseholdCharacteristics.new(nil, nil, self),
      Form::Lettings::Subsections::HouseholdNeeds.new(nil, nil, self),
      Form::Lettings::Subsections::HouseholdSituation.new(nil, nil, self),
    ]
  end
end
