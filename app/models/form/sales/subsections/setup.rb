class Form::Sales::Subsections::Setup < ::Form::Subsection
  def initialize(id, hsh, section)
    super
    @id = "setup"
    @label = "Set up this sales log"
    @section = section
  end

  def pages
    @pages ||= [
      Form::Sales::Setup::Pages::PurchaserCode.new(nil, nil, self),
      Form::Sales::Setup::Pages::SaleDate.new(nil, nil, self),
    ]
  end
end
