class Form::Lettings::Pages::PropertyLocalAuthority < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "property_local_authority"
    @depends_on = [
      { "is_la_inferred" => false, "is_general_needs?" => true, "form.start_year_2024_or_later?" => false },
      { "is_la_inferred" => false, "is_general_needs?" => true, "form.start_year_2024_or_later?" => true, "address_search_given?" => true },
    ]
  end

  def questions
    @questions ||= [Form::Lettings::Questions::La.new(nil, nil, self)]
  end
end
