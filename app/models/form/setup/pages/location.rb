class Form::Setup::Pages::Location < ::Form::Page
  def initialize(_id, hsh, subsection)
    super("location", hsh, subsection)
    @header = ""
    @description = ""
    @questions = questions
    # Only display if there is more than one location
    @depends_on = [{
      "supported_housing_schemes_enabled?" => true,
      "needstype" => 2,
      "scheme.locations.size" => {
        "operator" => ">",
        "operand" => 1,
      },
    }]
    @derived = true
  end

  def questions
    [
      Form::Setup::Questions::Location.new(nil, nil, self),
    ]
  end
end
