class Form::Sales::Pages::PropertyLocalAuthority < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "property_local_authority"
    @depends_on = [
      { "is_la_inferred" => false, "form.start_year_2025_or_later?" => false, "address_search_given?" => true },
      { "is_la_inferred" => false, "form.start_year_2025_or_later?" => true },
    ]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::PropertyLocalAuthority.new(nil, nil, self),
    ]
  end
end
