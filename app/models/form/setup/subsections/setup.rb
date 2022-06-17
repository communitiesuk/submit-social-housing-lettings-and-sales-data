class Form::Subsections::Setup < ::Form::Subsection
  def initialize(id, hsh, section)
    super
    @id = "setup"
    @label = "Set up this lettings log"
    @pages = [pages]
    @section = section
  end

  def pages
    [
      Form::Setup::Pages::Organisation.new(nil, nil, self),
      Form::Setup::Pages::NeedsType.new(nil, nil, self),
      Form::Setup::Pages::Renewal.new(nil, nil, self),
      Form::Setup::Pages::TenancyStartDate.new(nil, nil, self),
      Form::Setup::Pages::RentType.new(nil, nil, self),
      Form::Setup::Pages::TenantCode.new(nil, nil, self),
      Form::Setup::Pages::PropertyReference.new(nil, nil, self),
    ]
  end
end
