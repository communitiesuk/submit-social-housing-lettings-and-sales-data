class Form::Lettings::Pages::LeadTenantEthnicBackgroundAsian < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "lead_tenant_ethnic_background_asian"
    @depends_on = [{ "ethnic_group" => 2 }]
  end

  def questions
    @questions ||= [Form::Lettings::Questions::EthnicAsian.new(nil, nil, self)]
  end
end
