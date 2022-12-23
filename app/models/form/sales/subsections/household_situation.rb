class Form::Sales::Subsections::HouseholdSituation < ::Form::Subsection
  def initialize(id, hsh, section)
    super
    @id = "household_situation"
    @label = "Household situation"
    @section = section
    @depends_on = [{ "setup_completed?" => true }]
  end

  def pages
    @pages ||= [
      Form::Sales::Pages::BuyersOrganisations.new(nil, nil, self),
    ]
  end
end
