class Form::Lettings::Pages::LeadTenantWorkingSituation < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "lead_tenant_working_situation"
    @depends_on = [{ "declaration" => 1 }]
  end

  def questions
    @questions ||= [Form::Lettings::Questions::WorkingSituation1.new(nil, nil, self)]
  end
end
