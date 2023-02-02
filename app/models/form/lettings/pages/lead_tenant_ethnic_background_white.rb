class Form::Lettings::Pages::LeadTenantEthnicBackgroundWhite < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "lead_tenant_ethnic_background_white"
    @depends_on = [{ "ethnic_group" => 0 }]
  end

  def questions
    @questions ||= [Form::Lettings::Questions::EthnicWhite.new(nil, nil, self)]
  end
end
