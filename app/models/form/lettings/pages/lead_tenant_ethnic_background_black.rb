class Form::Lettings::Pages::LeadTenantEthnicBackgroundBlack < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "lead_tenant_ethnic_background_black"
    @header = ""
    @depends_on = [{ "ethnic_group" => 3 }]
    @description = ""
  end

  def questions
    @questions ||= [Form::Lettings::Questions::Ethnic.new(nil, nil, self)]
  end
end
