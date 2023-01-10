class Form::Lettings::Pages::Location < ::Form::Page
  def initialize(_id, hsh, subsection)
    super("location", hsh, subsection)
    @header = ""
    @depends_on = [{
      "needstype" => 2,
      "scheme_has_multiple_locations?" => true,
    }]
    @next_unresolved_page_id = :check_answers
  end

  def questions
    @questions ||= [
      Form::Lettings::Questions::LocationId.new(nil, nil, self),
    ]
  end
end
