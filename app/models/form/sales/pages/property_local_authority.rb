class Form::Sales::Pages::PropertyLocalAuthority < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "property_local_authority"
    @depends_on = [
      { "is_la_inferred" => false, "form.start_year_after_2024?" => false },
      { "is_la_inferred" => false, "form.start_year_after_2024?" => true, "address_search_given?" => true },
    ]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::PropertyLocalAuthority.new(nil, nil, self),
    ]
  end
end
