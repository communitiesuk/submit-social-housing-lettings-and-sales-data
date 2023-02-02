class Form::Lettings::Pages::LeadTenantGenderIdentity < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "lead_tenant_gender_identity"
    @depends_on = [{ "declaration" => 1 }]
  end

  def questions
    @questions ||= [Form::Lettings::Questions::GenderIdentity1.new(nil, nil, self)]
  end
end
