class Form::Lettings::Pages::TenancyLength < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "tenancy_length"
    @depends_on = [{ "tenancy_type_fixed_term?" => true }]
  end

  def questions
    @questions ||= [Form::Lettings::Questions::TenancyLength.new(nil, nil, self)]
  end
end
