class Form::Lettings::Subsections::PropertyInformation < ::Form::Subsection
  def initialize(id, hsh, section)
    super
    @id = "property_information"
    @label = "Property information"
    @depends_on = [{ "non_location_setup_questions_completed?" => true }]
  end

  def pages
    @pages ||= [
      (first_let_questions if form.start_year_2025_or_later?),
      uprn_questions,
      Form::Lettings::Pages::PropertyLocalAuthority.new(nil, nil, self),
      Form::Lettings::Pages::RentValueCheck.new("local_authority_rent_value_check", nil, self),
      (first_let_questions unless form.start_year_2025_or_later?),
      number_of_times_relet,
      Form::Lettings::Pages::PropertyUnitType.new(nil, nil, self),
      Form::Lettings::Pages::PropertyBuildingType.new(nil, nil, self),
      Form::Lettings::Pages::PropertyWheelchairAccessible.new(nil, nil, self),
      Form::Lettings::Pages::PropertyNumberOfBedrooms.new(nil, nil, self),
      Form::Lettings::Pages::RentValueCheck.new("beds_rent_value_check", nil, self),
      Form::Lettings::Pages::VoidDate.new(nil, nil, self),
      Form::Lettings::Pages::VoidDateValueCheck.new(nil, nil, self),
      Form::Lettings::Pages::PropertyMajorRepairs.new(nil, nil, self),
      Form::Lettings::Pages::PropertyMajorRepairsValueCheck.new(nil, nil, self),
      (Form::Lettings::Pages::ShelteredAccommodation.new(nil, nil, self) if form.start_year_2025_or_later?),
    ].flatten.compact
  end

  def uprn_questions
    if form.start_year_2024_or_later?
      [
        Form::Lettings::Pages::AddressSearch.new(nil, nil, self),
        Form::Lettings::Pages::AddressFallback.new(nil, nil, self),
      ]
    else
      [
        Form::Lettings::Pages::Uprn.new(nil, nil, self),
        Form::Lettings::Pages::UprnConfirmation.new(nil, nil, self),
        Form::Lettings::Pages::Address.new(nil, nil, self),
      ]
    end
  end

  def number_of_times_relet
    Form::Lettings::Pages::PropertyNumberOfTimesRelet.new(nil, nil, self) unless form.start_year_2024_or_later?
  end

  def first_let_questions
    [
      Form::Lettings::Pages::FirstTimePropertyLetAsSocialHousing.new(nil, nil, self),
      Form::Lettings::Pages::PropertyLetType.new(nil, nil, self),
      Form::Lettings::Pages::PropertyVacancyReasonNotFirstLet.new(nil, nil, self),
      Form::Lettings::Pages::PropertyVacancyReasonFirstLet.new(nil, nil, self),
    ]
  end

  def displayed_in_tasklist?(log)
    return true if form.start_year_2025_or_later?

    !(log.is_supported_housing? && log.is_renewal?)
  end
end
