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
      stock_owner_page,
      Form::Lettings::Pages::MinRentValueCheck.new("stock_owner_min_rent_value_check", nil, self),
      Form::Lettings::Pages::MaxRentValueCheck.new("stock_owner_max_rent_value_check", nil, self),
      managing_organisation_page,
      created_by_page,
      Form::Lettings::Pages::NeedsType.new(nil, nil, self),
      Form::Lettings::Pages::Scheme.new(nil, nil, self),
      Form::Lettings::Pages::Location.new(nil, nil, self),
      Form::Lettings::Pages::MinRentValueCheck.new("needs_type_min_rent_value_check", nil, self),
      Form::Lettings::Pages::MaxRentValueCheck.new("needs_type_max_rent_value_check", nil, self),
      Form::Lettings::Pages::Renewal.new(nil, nil, self),
      Form::Lettings::Pages::TenancyStartDate.new(nil, nil, self),
      Form::Lettings::Pages::MinRentValueCheck.new("start_date_min_rent_value_check", nil, self),
      Form::Lettings::Pages::MaxRentValueCheck.new("start_date_max_rent_value_check", nil, self),
      Form::Lettings::Pages::RentType.new(nil, nil, self),
      Form::Lettings::Pages::MinRentValueCheck.new("rent_type_min_rent_value_check", nil, self),
      Form::Lettings::Pages::MaxRentValueCheck.new("rent_type_max_rent_value_check", nil, self),
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

  def stock_owner_page
    return unless FeatureToggle.managing_for_other_user_enabled?

    Form::Lettings::Pages::StockOwner.new(nil, nil, self)
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
