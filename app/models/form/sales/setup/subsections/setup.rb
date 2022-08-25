class Form::Sales::Setup::Subsections::Setup < ::Form::Subsection
  def initialize(id, hsh, section)
    super
    @id = "setup"
    @label = "Set up this sales log"
    @section = section
  end

  def pages
    @pages ||= [
      Form::Sales::Setup::Pages::SaleDate.new(nil, nil, self),
    ]
  end
end
