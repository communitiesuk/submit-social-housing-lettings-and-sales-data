class Form::Setup::Pages::Scheme < ::Form::Page
  def initialize(_id, hsh, subsection)
    super("scheme", hsh, subsection)
    @header = ""
    @description = ""
    @depends_on = [{
      "supported_housing_schemes_enabled?" => true,
      "needstype" => 2,
    }]
  end

  def questions
    @questions ||= [
      Form::Setup::Questions::SchemeId.new(nil, nil, self),
    ]
  end
end
