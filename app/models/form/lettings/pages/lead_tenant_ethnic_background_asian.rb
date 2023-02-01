class Form::Lettings::Pages::LeadTenantEthnicBackgroundAsian < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "lead_tenant_ethnic_background_asian"
    @header = ""
    @depends_on = [{ "ethnic_group" => 2 }]
    @description = ""
  end

  def questions
    @questions ||= [Form::Lettings::Questions::EthnicAsian.new(nil, nil, self)]
  end
end
