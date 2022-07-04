class Form::Setup::Pages::Location < ::Form::Page
  def initialize(_id, hsh, subsection)
    super("location", hsh, subsection)
    @header = ""
    @description = ""
    @questions = questions
    @depends_on = [{
      "supported_housing_schemes_enabled?" => true,
      "needstype" => 2,
      "scheme_has_multiple_locations?" => true,
    }]
  end

  def questions
    [
      Form::Setup::Questions::LocationId.new(nil, nil, self),
    ]
  end
end
