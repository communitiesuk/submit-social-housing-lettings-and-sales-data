class Form::Sales::Subsections::HouseholdSituation < ::Form::Subsection
  def initialize(id, hsh, section)
    super
    @id = "household_situation"
    @label = "Household situation"
  end

  def depends_on
    if form.start_year_2025_or_later?
      [{ "setup_completed?" => true, "is_staircase?" => false }]
    else
      [{ "setup_completed?" => true }]
    end
  end

  def pages
    @pages ||= [
      Form::Sales::Pages::Buyer1PreviousTenure.new(nil, nil, self),
      Form::Sales::Pages::LastAccommodation.new(nil, nil, self),
      Form::Sales::Pages::LastAccommodationLa.new(nil, nil, self),
      (Form::Sales::Pages::BuyersOrganisations.new(nil, nil, self) unless form.start_year_2025_or_later?),
      Form::Sales::Pages::Buyer2LivingIn.new(nil, nil, self),
      Form::Sales::Pages::Buyer2PreviousHousingSituation.new(nil, nil, self),
    ].flatten.compact
  end

  def displayed_in_tasklist?(log)
    return true unless form.start_year_2025_or_later?

    log.staircase != 1
  end
end
