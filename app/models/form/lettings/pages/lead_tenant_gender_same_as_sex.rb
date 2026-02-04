class Form::Lettings::Pages::LeadTenantGenderSameAsSex < ::Form::Page
  def initialize(id, hsh, subsection)
    super(id, hsh, subsection)
    @id = "lead_tenant_gender_same_as_sex"
    @depends_on = [{ "declaration" => 1 }]
  end

  def questions
    @questions ||= [
      Form::Lettings::Questions::GenderSameAsSex.new(nil, nil, self, person_index: 1),
    ]
  end
end
