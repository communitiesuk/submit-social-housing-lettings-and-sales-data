class Form::Lettings::Pages::LeadTenantNationality < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "lead_tenant_nationality"
    @depends_on = [{ "declaration" => 1 }]
  end

  def questions
    @questions ||= if form.start_year_after_2024?
                     [
                       Form::Lettings::Questions::NationalityAllGroup.new(nil, nil, self),
                       Form::Lettings::Questions::NationalityAll.new(nil, nil, self),
                     ]
                   else
                     [Form::Lettings::Questions::Nationality.new(nil, nil, self)]
                   end
  end
end
