class Form::Lettings::Subsections::Setup < ::Form::Subsection
  def initialize(id, hsh, section)
    super
    @id = "setup"
    @label = "Set up this lettings log"
    @section = section
  end

  def pages
    @pages ||= [
      organisation_page,
      housing_provider_page,
      managing_organisation_page,
      created_by_page,
      Form::Lettings::Pages::NeedsType.new(nil, nil, self),
      Form::Lettings::Pages::Scheme.new(nil, nil, self),
      Form::Lettings::Pages::Location.new(nil, nil, self),
      Form::Lettings::Pages::Renewal.new(nil, nil, self),
      Form::Lettings::Pages::TenancyStartDate.new(nil, nil, self),
      Form::Lettings::Pages::RentType.new(nil, nil, self),
      Form::Lettings::Pages::TenantCode.new(nil, nil, self),
      Form::Lettings::Pages::PropertyReference.new(nil, nil, self),
    ].compact
  end

  def enabled?(_lettings_log)
    true
  end

private

  def organisation_page
    return if FeatureToggle.managing_for_other_user_enabled?

    Form::Common::Pages::Organisation.new(nil, nil, self)
  end

  def housing_provider_page
    return unless FeatureToggle.managing_for_other_user_enabled?

    Form::Lettings::Pages::HousingProvider.new(nil, nil, self)
  end

  def managing_organisation_page
    return unless FeatureToggle.managing_for_other_user_enabled?

    Form::Lettings::Pages::ManagingOrganisation.new(nil, nil, self)
  end

  def created_by_page
    if FeatureToggle.managing_for_other_user_enabled?
      Form::Lettings::Pages::CreatedBy.new(nil, nil, self)
    else
      Form::Common::Pages::CreatedBy.new(nil, nil, self)
    end
  end
end
