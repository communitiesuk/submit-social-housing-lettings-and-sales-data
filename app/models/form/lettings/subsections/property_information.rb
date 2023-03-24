class Form::Lettings::Subsections::PropertyInformation < ::Form::Subsection
  def initialize(id, hsh, section)
    super
    @id = "property_information"
    @label = "Property information"
    @depends_on = [{ "non_location_setup_questions_completed?" => true }]
  end

  def pages
    @pages ||= [
      uprn_questions,
      Form::Lettings::Pages::PropertyLocalAuthority.new(nil, nil, self),
      Form::Lettings::Pages::FirstTimePropertyLetAsSocialHousing.new(nil, nil, self),
      Form::Lettings::Pages::PropertyLetType.new(nil, nil, self),
      Form::Lettings::Pages::PropertyVacancyReasonNotFirstLet.new(nil, nil, self),
      Form::Lettings::Pages::PropertyVacancyReasonFirstLet.new(nil, nil, self),
      Form::Lettings::Pages::PropertyNumberOfTimesReletNotSocialLet.new(nil, nil, self),
      Form::Lettings::Pages::PropertyNumberOfTimesReletSocialLet.new(nil, nil, self),
      Form::Lettings::Pages::PropertyUnitType.new(nil, nil, self),
      Form::Lettings::Pages::PropertyBuildingType.new(nil, nil, self),
      Form::Lettings::Pages::PropertyWheelchairAccessible.new(nil, nil, self),
      Form::Lettings::Pages::PropertyNumberOfBedrooms.new(nil, nil, self),
      Form::Lettings::Pages::VoidDate.new(nil, nil, self),
      Form::Lettings::Pages::VoidDateValueCheck.new(nil, nil, self),
      Form::Lettings::Pages::NewBuildHandoverDate.new(nil, nil, self),
      Form::Lettings::Pages::PropertyMajorRepairs.new(nil, nil, self),
      Form::Lettings::Pages::PropertyMajorRepairsValueCheck.new(nil, nil, self),
    ].flatten.compact
  end

  def uprn_questions
    if form.start_date.year >= 2023
      [
        Form::Lettings::Pages::UprnKnown.new(nil, nil, self),
        Form::Lettings::Pages::Uprn.new(nil, nil, self),
        Form::Lettings::Pages::UprnConfirmation.new(nil, nil, self),
        Form::Lettings::Pages::Address.new(nil, nil, self),
      ]
    else
      [
        Form::Lettings::Pages::PropertyPostcode.new(nil, nil, self),
      ]
    end
  end

  def displayed_in_tasklist?(log)
    !(log.is_supported_housing? && log.is_renewal?)
  end
end
