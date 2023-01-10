class Form::Sales::Sections::Setup < ::Form::Section
  def initialize(id, hsh, form)
    super
    @id = "setup"
    @label = "Before you start"
    @description = ""
    @subsections = [Form::Sales::Subsections::Setup.new(nil, nil, self)] || []
  end
end
