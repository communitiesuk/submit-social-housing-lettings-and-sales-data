class Form::Sales::Subsections::HouseholdSituation < ::Form::Subsection
  def initialize(id, hsh, section)
    super
    @id = "household_situation"
    @label = "Household situation"
    @depends_on = [{ "setup_completed?" => true }]
  end

  def pages
    @pages ||= [
      Form::Sales::Pages::Buyer1PreviousTenure.new(nil, nil, self),
      Form::Sales::Pages::LastAccommodation.new(nil, nil, self),
      Form::Sales::Pages::LastAccommodationLa.new(nil, nil, self),
      Form::Sales::Pages::BuyersOrganisations.new(nil, nil, self),
      buyer_2_situation_pages,
    ].flatten.compact
  end

  def buyer_2_situation_pages
    if form.start_date.year >= 2023
      [
        Form::Sales::Pages::Buyer2LivingIn.new(nil, nil, self),
        Form::Sales::Pages::Buyer2PreviousHousingSituation.new(nil, nil, self),
      ]
    end
  end
end
