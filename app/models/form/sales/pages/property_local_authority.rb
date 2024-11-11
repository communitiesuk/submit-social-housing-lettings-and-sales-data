class Form::Sales::Pages::PropertyLocalAuthority < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "property_local_authority"
    @depends_on = [
      { "is_la_inferred" => false, "form.start_year_2024_or_later?" => false },
      { "is_la_inferred" => false, "form.start_year_2024_or_later?" => true, "address_search_given?" => true },
    ]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::PropertyLocalAuthority.new(nil, nil, self),
    ]
  end
end
