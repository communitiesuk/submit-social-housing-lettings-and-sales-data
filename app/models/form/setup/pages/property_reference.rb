class Form::Setup::Pages::PropertyReference < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "property_reference"
    @header = ""
    @description = ""
    @questions = questions
    @subsection = subsection
  end

  def questions
    [
      Form::Setup::Questions::PropertyReference.new(nil, nil, self),
    ]
  end
end
