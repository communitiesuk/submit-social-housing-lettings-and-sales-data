class Form::Lettings::Pages::TenancyLengthIntermediateRent < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "tenancy_length_intermediate_rent"
    @copy_key = "lettings.tenancy_information.tenancylength.tenancy_length_intermediate_rent"
    @depends_on = [{ "tenancy_type_fixed_term?" => true, "affordable_or_social_rent?" => false, "needstype" => 1 }]
  end

  def questions
    @questions ||= [Form::Lettings::Questions::TenancyLengthIntermediateRent.new(nil, nil, self)]
  end
end
