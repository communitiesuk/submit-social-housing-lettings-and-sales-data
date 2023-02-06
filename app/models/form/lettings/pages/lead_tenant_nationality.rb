class Form::Lettings::Pages::LeadTenantNationality < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "lead_tenant_nationality"
    @depends_on = [{ "declaration" => 1 }]
  end

  def questions
    @questions ||= [Form::Lettings::Questions::National.new(nil, nil, self)]
  end
end
