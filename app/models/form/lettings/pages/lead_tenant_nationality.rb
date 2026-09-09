class Form::Lettings::Pages::LeadTenantNationality < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "lead_tenant_nationality"
    @copy_key = "lettings.household_characteristics.nationality_all"
    @depends_on = [{ "declaration" => 1 }]
  end

  def questions
    @questions ||= [
      Form::Lettings::Questions::NationalityAllGroup.new(nil, nil, self),
      Form::Lettings::Questions::NationalityAll.new(nil, nil, self),
    ]
  end
end
