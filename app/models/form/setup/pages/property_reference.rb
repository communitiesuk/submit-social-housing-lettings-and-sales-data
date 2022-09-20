class Form::Setup::Pages::PropertyReference < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "property_reference"
    @header = ""
    @description = ""
    @subsection = subsection
  end

  def questions
    @questions ||= [
      Form::Setup::Questions::PropertyReference.new(nil, nil, self),
    ]
  end
end
