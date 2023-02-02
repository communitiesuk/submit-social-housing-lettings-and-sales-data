class Form::Lettings::Subsections::PropertyInformation < ::Form::Subsection
  def initialize(id, hsh, section)
    super
    @id = "property_information"
    @label = "Property information"
    @depends_on = [{ "non_location_setup_questions_completed?" => true }]
  end

  def pages
    @pages ||= [
      Form::Lettings::Pages::PropertyPostcode.new(nil, nil, self),
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
      Form::Lettings::Pages::VoidOrRenewalDate.new(nil, nil, self),
      Form::Lettings::Pages::VoidDateValueCheck.new(nil, nil, self),
      Form::Lettings::Pages::NewBuildHandoverDate.new(nil, nil, self),
      Form::Lettings::Pages::PropertyMajorRepairs.new(nil, nil, self),
      Form::Lettings::Pages::PropertyMajorRepairsValueCheck.new(nil, nil, self),
    ].compact
  end
end
