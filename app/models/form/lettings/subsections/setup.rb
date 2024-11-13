class Form::Lettings::Subsections::Setup < ::Form::Subsection
  def initialize(id, hsh, section)
    super
    @id = "setup"
    @label = "Set up this lettings log"
    @section = section
  end

  def pages
    @pages ||= [
      Form::Lettings::Pages::StockOwner.new(nil, nil, self),
      Form::Lettings::Pages::ManagingOrganisation.new(nil, nil, self),
      Form::Lettings::Pages::CreatedBy.new(nil, nil, self),
      Form::Lettings::Pages::NeedsType.new(nil, nil, self),
      Form::Lettings::Pages::Scheme.new(nil, nil, self),
      Form::Lettings::Pages::Location.new(nil, nil, self),
      Form::Lettings::Pages::LocationSearch.new(nil, nil, self),
      Form::Lettings::Pages::Renewal.new(nil, nil, self),
      Form::Lettings::Pages::TenancyStartDate.new(nil, nil, self),
      Form::Lettings::Pages::RentType.new(nil, nil, self),
      Form::Lettings::Pages::TenantCode.new(nil, nil, self),
      Form::Lettings::Pages::PropertyReference.new(nil, nil, self),
      (Form::Lettings::Pages::Declaration.new(nil, nil, self) if form.start_year_2024_or_later?),
    ].compact
  end

  def enabled?(_lettings_log)
    true
  end
end
