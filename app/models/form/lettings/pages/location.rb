class Form::Lettings::Pages::Location < ::Form::Page
  def initialize(_id, hsh, subsection)
    super("location", hsh, subsection)
    @depends_on = [
      {
        "needstype" => 2,
        "scheme_has_multiple_locations?" => true,
        "scheme_has_large_number_of_locations?" => false,
      },
    ]
    @copy_key = "lettings.setup.location_id.less_than_twenty"
    @next_unresolved_page_id = :check_answers
  end

  def questions
    @questions ||= [
      Form::Lettings::Questions::LocationId.new(nil, nil, self),
    ]
  end
end
