class Form::Lettings::Pages::TenancyLengthAffordableRent < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "tenancy_length_affordable_rent"
    @copy_key = "lettings.tenancy_information.tenancylength.tenancy_length_affordable_rent"
    @depends_on = [{ "tenancy_type_fixed_term?" => true, "affordable_or_social_rent?" => true, "needstype" => 1 }]
  end

  def questions
    @questions ||= [Form::Lettings::Questions::TenancyLengthAffordableRent.new(nil, nil, self)]
  end
end
