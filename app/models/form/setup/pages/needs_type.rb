class Form::Setup::Pages::NeedsType < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "needs_type"
    @header = ""
    @description = ""
    @questions = questions
    @depends_on = [{ "supported_housing_schemes_enabled?" => true }]
    @subsection = subsection
  end

  def questions
    [
      Form::Setup::Questions::NeedsType.new(nil, nil, self),
    ]
  end
end
