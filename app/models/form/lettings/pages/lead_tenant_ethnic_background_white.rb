class Form::Lettings::Pages::LeadTenantEthnicBackgroundWhite < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "lead_tenant_ethnic_background_white"
    @header = ""
    @depends_on = [{ "ethnic_group" => 0 }]
    @description = ""
  end

  def questions
    @questions ||= [Form::Lettings::Questions::Ethnic.new(nil, nil, self)]
  end
end
