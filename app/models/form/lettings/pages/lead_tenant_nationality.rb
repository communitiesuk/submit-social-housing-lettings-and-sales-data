class Form::Lettings::Pages::LeadTenantNationality < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "lead_tenant_nationality"
    @header = ""
    @depends_on = [{ "declaration" => 1 }]
    @description = ""
  end

  def questions
    @questions ||= [Form::Lettings::Questions::National.new(nil, nil, self)]
  end
end
