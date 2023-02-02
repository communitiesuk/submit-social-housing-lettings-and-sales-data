class Form::Lettings::Pages::LeadTenantEthnicGroup < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "lead_tenant_ethnic_group"
    @depends_on = [{ "declaration" => 1 }]
  end

  def questions
    @questions ||= [Form::Lettings::Questions::EthnicGroup.new(nil, nil, self)]
  end
end
