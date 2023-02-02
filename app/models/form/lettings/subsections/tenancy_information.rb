class Form::Lettings::Subsections::TenancyInformation < ::Form::Subsection
  def initialize(id, hsh, section)
    super
    @id = "tenancy_information"
    @label = "Tenancy information"
    @depends_on = [{ "non_location_setup_questions_completed?" => true }]
  end

  def pages
    @pages ||= [
      Form::Lettings::Pages::Joint.new("joint", nil, self),
      Form::Lettings::Pages::StarterTenancy.new("starter_tenancy", nil, self),
      Form::Lettings::Pages::TenancyType.new(nil, nil, self),
      Form::Lettings::Pages::StarterTenancyType.new(nil, nil, self),
      Form::Lettings::Pages::TenancyLength.new(nil, nil, self),
      Form::Lettings::Pages::Shelteredaccom.new(nil, nil, self),
    ].compact
  end
end
