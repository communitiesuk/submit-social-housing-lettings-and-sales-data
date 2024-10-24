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
      la_known_question,
      Form::Sales::Questions::PropertyLocalAuthority.new(nil, nil, self),
    ].compact
  end

  def la_known_question
    if form.start_date.year < 2023
      Form::Sales::Questions::PropertyLocalAuthorityKnown.new(nil, nil, self)
    end
  end
end
