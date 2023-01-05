class Form::Sales::Sections::Household < ::Form::Section
  def initialize(id, hsh, form)
    super
    @id = "household"
    @label = "About the household"
    @description = ""
    @form = form
    @subsections = [
      Form::Sales::Subsections::HouseholdCharacteristics.new(nil, nil, self),
      Form::Sales::Subsections::HouseholdSituation.new(nil, nil, self),
      Form::Sales::Subsections::HouseholdNeeds.new(nil, nil, self),
    ]
  end
end
