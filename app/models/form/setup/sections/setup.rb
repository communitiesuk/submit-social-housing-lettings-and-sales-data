class Form::Sections::Setup < ::Form::Section
  def initialize(id, hsh, form)
    super
    @id = "setup"
    @label = "Before you start"
    @description = ""
    @form = form
    @subsections = [Form::Setup::Subsections::Setup.new(nil, nil, self)]
  end
end
