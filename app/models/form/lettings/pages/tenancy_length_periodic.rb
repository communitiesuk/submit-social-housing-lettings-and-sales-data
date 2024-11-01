class Form::Lettings::Pages::TenancyLengthPeriodic < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "tenancy_length_periodic"
    @copy_key = "lettings.tenancy_information.tenancylength.tenancy_length_periodic"
    @depends_on = [{ "tenancy_type_periodic?" => true }]
  end

  def questions
    @questions ||= [Form::Lettings::Questions::TenancyLengthPeriodic.new(nil, nil, self)]
  end
end
