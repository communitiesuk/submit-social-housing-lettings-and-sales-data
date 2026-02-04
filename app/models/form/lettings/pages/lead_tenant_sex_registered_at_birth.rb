class Form::Lettings::Pages::LeadTenantSexRegisteredAtBirth < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "lead_tenant_sex_registered_at_birth"
    @depends_on = [{ "declaration" => 1 }]
  end

  def questions
    @questions ||= [
      Form::Lettings::Questions::LeadTenantSexRegisteredAtBirth.new(nil, nil, self),
    ]
  end
end
