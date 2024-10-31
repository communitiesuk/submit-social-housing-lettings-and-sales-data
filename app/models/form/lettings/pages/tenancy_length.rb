class Form::Lettings::Pages::TenancyLength < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "tenancy_length"
    @copy_key = "lettings.tenancy_information.tenancylength.tenancy_length"
    @depends_on = [{ "tenancy_type_fixed_term?" => true, "needstype" => 2 }]
  end

  def questions
    @questions ||= [Form::Lettings::Questions::TenancyLength.new(nil, nil, self)]
  end
end
