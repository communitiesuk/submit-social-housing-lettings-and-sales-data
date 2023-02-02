class Form::Lettings::Sections::TenancyAndProperty < ::Form::Section
  def initialize(id, hsh, form)
    super
    @id = "tenancy_and_property"
    @label = "Property and tenancy information"
    @form = form
    @subsections = [
      Form::Lettings::Subsections::PropertyInformation.new(nil, nil, self),
      Form::Lettings::Subsections::TenancyInformation.new(nil, nil, self),
    ]
  end
end
