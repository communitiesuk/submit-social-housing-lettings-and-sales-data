class Form::Lettings::Sections::Setup < ::Form::Section
  def initialize(id, hsh, form)
    super
    @id = "setup"
    @label = "Before you start"
    @description = ""
    @form = form
    @subsections = [Form::Lettings::Subsections::Setup.new(nil, nil, self)]
  end
end
