class Form::Sales::Subsections::HouseholdCharacteristics < ::Form::Subsection
  def initialize(id, hsh, section)
    super
    @id = "household_characteristics"
    @label = "Household characteristics"
    @section = section
    @depends_on = [{ "setup" => "completed" }]
  end

  def pages
    @pages ||= [
      Form::Sales::Pages::Age1.new(nil, nil, self),
      Form::Sales::Pages::GenderIdentity1.new(nil, nil, self),
      Form::Sales::Pages::Buyer1LiveInProperty.new(nil, nil, self),
      Form::Sales::Pages::Buyer2RelationshipToBuyer1.new(nil, nil, self),
    ]
  end
end
