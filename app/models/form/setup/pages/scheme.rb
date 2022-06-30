class Form::Setup::Pages::Scheme < ::Form::Page
  def initialize(_id, hsh, subsection)
    super("scheme", hsh, subsection)
    @header = ""
    @description = ""
    @questions = questions
    @depends_on = [{
      "supported_housing_schemes_enabled?" => true,
      "needstype" => 2,
    }]
    @derived = true
  end

  def questions
    [
      Form::Setup::Questions::SchemeId.new(nil, nil, self),
    ]
  end
end
