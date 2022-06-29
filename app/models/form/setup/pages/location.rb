class Form::Setup::Pages::Location < ::Form::Page
  def initialize(id, hsh, subsection)
    super("location", hsh, subsection)
    @header = ""
    @description = ""
    @questions = questions
    # Only display if there is more than one location
    @depends_on = [{
                     "supported_housing_schemes_enabled?" => true,
                    #  scheme.locations.size > 1 => true
                   }]
    @derived = true
  end

  def questions
    [
      Form::Setup::Questions::Location.new(nil, nil, self)
    ]
  end
end
