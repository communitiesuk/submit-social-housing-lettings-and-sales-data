class Form::Lettings::Pages::LeadTenantEthnicBackgroundMixed < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "lead_tenant_ethnic_background_mixed"
    @header = ""
    @depends_on = [{ "ethnic_group" => 1 }]
    @description = ""
  end

  def questions
    @questions ||= [Form::Lettings::Questions::EthnicMixed.new(nil, nil, self)]
  end
end
