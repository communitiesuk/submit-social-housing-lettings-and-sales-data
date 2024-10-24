class Form::Lettings::Pages::LocationSearch < ::Form::Page
  def initialize(_id, hsh, subsection)
    super("location_search", hsh, subsection)
    @depends_on = [
      {
        "needstype" => 2,
        "scheme_has_multiple_locations?" => true,
        "scheme_has_large_number_of_locations?" => true,
      },
    ]
    @next_unresolved_page_id = :check_answers
  end

  def questions
    @questions ||= [
      Form::Lettings::Questions::LocationIdSearch.new(nil, nil, self),
    ]
  end
end
